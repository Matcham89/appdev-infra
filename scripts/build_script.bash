#!/bin/bash
source bootstrap_config.sh

# Install jq
if ! command -v jq &> /dev/null; then
    echo "Please install jq"
fi

# Install gh
if ! command -v gh &> /dev/null; then
    echo "Please install gh"
fi

# Install gcloud
if ! command -v gcloud &> /dev/null; then
    echo "Please install gcloud"
fi

# Prompt
echo "Please ensure you are working on a clean branch off of 'main'"

# Log in to google cloud
echo "Are you ready to log into Google Cloud (y/n)?"
read login_response
if [[ $login_response == "y" ]]; then 
  gcloud auth application-default login
fi

# Log in to GitHub
echo "Are you ready to log into GitHub (y/n)?"
read login_response
if [[ $login_response == "y" ]]; then 
  gh auth login
fi

# Create projects (y/n)
echo "Do the projects need to be created? (y/n)"
read create_project 

# At what level is the project being created
if [[ $create_project == "y" ]]; then 
  echo "Create the project at the organization level or folder level? (org/fld)"
  read project_level
fi

# Create the provided projects
if [[ "$folder_id" != "" && $create_project == "y" ]]; then
  gcloud projects create $cicd_project_id --folder=$folder_id
  gcloud projects create $dev_project_id --folder=$folder_id
elif [[ "$organization_id" != "" && $create_project == "y" ]]; then
  gcloud projects create $cicd_project_id --organization=$organization_id
  gcloud projects create $dev_project_id --organization=$organization_id
fi


# Enable required workload id permission
gcloud projects add-iam-policy-binding $cicd_project_id \
    --member=user:$monitor_alerts_email --role=roles/iam.workloadIdentityPoolAdmin  \

# Enable required workload id permission
gcloud projects add-iam-policy-binding $dev_project_id \
    --member=user:$monitor_alerts_email --role=roles/iam.workloadIdentityPoolAdmin  \

# Enable billing for the newly created projects

gcloud beta billing projects link $cicd_project_id --billing-account $billing_account
gcloud beta billing projects link $dev_project_id --billing-account $billing_account


state_bucket_present=$(gcloud storage buckets list --project $cicd_project_id | grep $state_bucket)
# Create storage bucket
if [[ -z "$state_bucket_present" ]]; then
gcloud storage buckets create gs://$state_bucket --project $cicd_project_id --location $default_region
else
  echo "Storage Bucket Present"
fi

# Output the variables to a YAML file to be used in the bootstrap
cd bootstrap
cat <<EOF > bootstrap_config.yaml
  cicd_project_id: $cicd_project_id 
  dev_project_id: $dev_project_id
  default_region: $default_region
  image_repo_name: $image_repo_name
  cicd_attribute_repository: $cicd_attribute_repository
  app_attribute_repository: $app_attribute_repository
  state_bucket: $state_bucket
  monitor_alerts_email: $monitor_alerts_email
  resource_name: $resource_name
EOF

# Update backend
cat <<EOF > backend.tf
  terraform {
  backend "gcs" {
    bucket = "$state_bucket"
    prefix = "bootstrap"
   }
  }
EOF

# Update remote states
cd ../iac
cat <<EOF > remote_states.tf
data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "$state_bucket"
    prefix = "bootstrap"
  }
}

locals {
  default_region       = data.terraform_remote_state.bootstrap.outputs.default_region
  artifact_repo_id     = data.terraform_remote_state.bootstrap.outputs.google_artifact_registry_repository_name
  cicd_project_id      = data.terraform_remote_state.bootstrap.outputs.cicd_project_id
  monitor_alerts_email = data.terraform_remote_state.bootstrap.outputs.monitor_alerts_email
  attestor_name        = data.terraform_remote_state.bootstrap.outputs.attestor_name
  keyring_name         = data.terraform_remote_state.bootstrap.outputs.keyring_name
  key_name             = data.terraform_remote_state.bootstrap.outputs.key_name
  keyring_location     = data.terraform_remote_state.bootstrap.outputs.keyring_location
  resource_name        = data.terraform_remote_state.bootstrap.outputs.resource_name
  key_version          = data.terraform_remote_state.bootstrap.outputs.key_version
}
EOF

# Start Terraform deployment
echo "The Terraform plan will now begin"
cd ../bootstrap
echo "Terraform init"
terraform init 
echo "Terraform plan"
terraform plan -out ./.plan
echo "Please review the Terraform plan"

echo "Is the plan correct? (y/n)"
read terrafrom_plan_response

echo "Allowing time for the WIF api to enable"
echo "Please wait"
sleep 10

if [[ $terrafrom_plan_response == "y" ]]; then 
 echo "Terrafrom Apply will now run!"
fi 

echo "Terraform apply"
terraform apply ./.plan

# Confirm if applied correctly
echo "Did the apply succeed? (possible fail due to api timing) (y/n)"
read success_response

if [[ $success_response == "n" ]]; then 
 echo "Terrafrom Apply will now run!"
 terraform plan -out ./.plan
 terraform apply ./.plan
fi 

# Define vars for github secrets
CICD_WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw provider_full_id_cicd)
CICD_SERVICE_ACCOUNT=$(terraform output -raw github_service_account_cicd)
STATE_BUCKET=$(terraform output -raw STATE_BUCKET)
DEV_PROJECT_ID=$(terraform output -raw dev_project_id)
DEV_PROJECT_NUMBER=$(terraform output -raw dev_project_number) 
DEV_WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw provider_full_id_dev)
DEV_SERVICE_ACCOUNT=$(terraform output -raw github_service_account_dev)

# Create .env file for github secrets
cat <<EOF > .env
CICD_WORKLOAD_IDENTITY_PROVIDER: $CICD_WORKLOAD_IDENTITY_PROVIDER
CICD_SERVICE_ACCOUNT: $CICD_SERVICE_ACCOUNT
STATE_BUCKET: $STATE_BUCKET
DEV_PROJECT_ID: $DEV_PROJECT_ID
DEV_PROJECT_NUMBER: $DEV_PROJECT_NUMBER
RESOURCE_CLOUD_RUN: $resource_name
EOF

# Set github secrets for iac
gh secret set -f .env -R $cicd_attribute_repository

# Deploy cloud run basic app
echo "Running cloud run deployment"
gcloud run deploy $resource_name \
--image us-docker.pkg.dev/cloudrun/container/hello \
--allow-unauthenticated \
--ingress all \
--region $default_region \
--project $dev_project_id

# Remove no longer needed files
echo "Remove Terraform state lock and State file"
rm .terraform.lock.hcl
rm -rf .terraform
rm .plan
rm .env


# Change dir to iac
cd ../iac

export TF_VAR_project_id=$DEV_PROJECT_ID
export TF_VAR_project_number=$DEV_PROJECT_NUMBER
echo "Terraform init"
terraform init -backend-config="bucket=$state_bucket" -backend-config="prefix=dev"

echo "Terraform plan"
terraform plan -out ./.plan

echo "Please review the Terraform plan"

echo "Is the plan correct? (y/n)"
read terrafrom_plan_response

if [[ $terrafrom_plan_response == "y" ]]; then 
 echo "Terrafrom Apply will now run!"
elif [[ $terrafrom_plan_response == "n" ]]; then
 echo "Please update terraform file to resolve issues"
 exit
fi 

echo "Terraform apply"
terraform apply ./.plan

# Set github secrets for app
cat <<EOF > .env
DEV_WORKLOAD_IDENTITY_PROVIDER: $DEV_WORKLOAD_IDENTITY_PROVIDER
DEV_SERVICE_ACCOUNT: $DEV_SERVICE_ACCOUNT
STATE_BUCKET: $STATE_BUCKET
DEV_PROJECT_ID: $DEV_PROJECT_ID
DEV_PROJECT_NUMBER: $DEV_PROJECT_NUMBER
IMAGE_NAME: $resource_name
EOF

# Set ip address value of load balancer
LOAD_BALANCER_IP=$(terraform output -raw LOAD_BALANCER_IP)

# Set github secrets on application repo
gh secret set -f .env -R $app_attribute_repository


# Remove no longer needed files
echo "Remove Terraform state lock and State file"
rm .terraform.lock.hcl
rm -rf .terraform
rm .plan
rm .env

# Plan for application deployment
echo "Have you cloned the application repo and provided the 'app_attribute_repository'? (y/n)"
read app_repo_response

if [[ $app_repo_response == "y" ]]; then 
 echo "Application Development Workflow will now run!"
elif [[ $app_repo_response == "n" ]]; then
 echo "The build tool will now exit, please continue deployment through github actions."
 exit
fi 

# Run the application dev deployment workflow
gh workflow run dev_deployment.yml -R $app_attribute_repository

echo "Deploying"
sleep 3

# Set workflow status
WORKFLOW_STATUS=$(gh run list -R $app_attribute_repository --json status,databaseId,name,number | jq '.[0] | .status')
echo $WORKFLOW_STATUS

# Show status of workflow in terminal until complete
while [[ $WORKFLOW_STATUS == '"in_progress"' ]] || [[ $WORKFLOW_STATUS == '"queued"' ]] ; do
   gh run list -R $app_attribute_repository
   WORKFLOW_STATUS=$(gh run list -R $app_attribute_repository --json status,databaseId,name,number | jq '.[0] | .status')
   echo $WORKFLOW_STATUS
done

# When workflow complete echo complete
if [[ $WORKFLOW_STATUS == '"completed"' ]]; then
  echo "Workflow has completed"
fi

# Show the application dev deployment workflow running
echo "You can see the action below"
echo "https://github.com/$app_attribute_repository/actions"

echo "Waiting for the application to settle"
sleep 10
echo "Welcome to the application"
curl $LOAD_BALANCER_IP
echo http://$LOAD_BALANCER_IP

# Complete build
echo "Build is now complete"
