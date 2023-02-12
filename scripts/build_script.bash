#!/bin/bash

# Prompt
echo "Please ensure you are working on a clean branch off of 'main'"

# Provide google admin credentials
echo "Please provide the google cloud admin account being used (my-account@google.com)"
read admin_user_account

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

# Set name of the company
echo "Please enter the company name for the project"
read company_name

#Set the default region for the project
echo "Please enter the default region for the project (europe-west2)"
select default_region in europe-west1 europe-west2 europe-west3
do 
  echo $default_region
  break
done

# Create projects (y/n)
echo "Do the projects need to be created? (y/n)"
read create_project 

# At what level is the project being created
if [[ $create_project == "y" ]]; then 
  echo "Create the project at the organization level or folder level? (org/fld)"
  read project_level
fi

if [[ $project_level == "org" ]]; then 
  echo "Please provide the organization id number"
  read organization_id
elif [[ $project_level == "fld" ]]; then 
  echo "Please provide the folder id"
  read folder_id
fi 

# Name the CICD project
echo 'Please name the CICD project'
read cicd_project_id
echo "The CICD project will be name $cicd_project_id"

# Name the Dev project name
echo 'Please name the Dev project'
read dev_project_id
echo "The Dev project will be name $dev_project_id"

# Echo the project names if they dont need to be created
if [[ $create_project == "n" ]]; then
  echo "The name of the CICD project is $cicd_project_id and Dev project is $dev_project_id"
fi 

# Set name of the storage bucker for state files
echo "Please enter the name of the state file storage bucket to be deployed"
read state_bucket

# Set the name of the artifact repo
echo "Please enter the name of the artifact registry repo"
read image_repo_name

# Enter the ID of the GitHub repo for the Infrastructure
echo "Please enter the id of the GitHub repo for the infrastructure (OWNER/REPO)"
read cicd_attribute_repository

# Enter the ID of the GitHub repo for the Application
echo "Please enter the id of the GitHub repo for the infrastructure (OWNER/REPO)"
read app_attribute_repository

# Prepare cloud run for iac deployment
echo "In order to proceed, cloud run must deploy a template."
echo "Please provide the name for the Cloud Run resource"
read resource_name

# Create the provided projects
if [[ $project_level == "org" && $create_project == "y" ]]; then 
  gcloud projects create $cicd_project_id --organization=$organization_id
  gcloud projects create $dev_project_id --organization=$organization_id
elif [[ $project_level == "fld" && $create_project == "y" ]]; then 
  gcloud projects create $cicd_project_id --folder=$folder_id
  gcloud projects create $dev_project_id --folder=$folder_id
fi 

# Enable required workload id permission
gcloud projects add-iam-policy-binding $cicd_project_id \
    --member=user:$admin_user_account --role=roles/iam.workloadIdentityPoolAdmin  \

# Enable required workload id permission
gcloud projects add-iam-policy-binding $dev_project_id \
    --member=user:$admin_user_account --role=roles/iam.workloadIdentityPoolAdmin  \



# Enable billing for the newly created projects
gcloud beta billing accounts list
echo "Please provide the billing account 'ACCOUNT_ID' for the projects"
read billing_account
gcloud beta billing projects link $cicd_project_id --billing-account $billing_account
gcloud beta billing projects link $dev_project_id --billing-account $billing_account

# Create storage bucket
gcloud storage buckets create gs://$state_bucket-$cicd_project_id --project $cicd_project_id --location $default_region

# Output the variables to a YAML file to be used in the bootstrap
cd bootstrap
cat <<EOF > bootstrap_config.yaml
  cicd_project_id: $cicd_project_id 
  dev_project_id: $dev_project_id
  default_region: $default_region
  image_repo_name: $image_repo_name
  cicd_attribute_repository: $cicd_attribute_repository
  app_attribute_repository: $app_attribute_repository
  state_bucket: "${state_bucket}-${cicd_project_id}"
  monitor_alerts_email: $admin_user_account
  resource_name: $resource_name
EOF

# Update backend
cat <<EOF > backend.tf
  terraform {
  backend "gcs" {
    bucket = "${state_bucket}-${cicd_project_id}"
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
    bucket = "${state_bucket}-${cicd_project_id}"
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
  key_version          = data.terraform_remote_state.bootstrap.outputs.key_version
  resource_name        = data.terraform_remote_state.bootstrap.outputs.resource_name
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

if [[ $terrafrom_plan_response == "y" ]]; then 
 echo "Terrafrom Apply will now run!"
fi 

echo "Terraform apply"
terraform apply ./.plan

# Confirm if applied correctly
echo "Did the apply succeed ? (y/n)"
read success_response

if [[ $success_response == "n" ]]; then 
 echo "Terrafrom Apply will now run!"
 terraform plan -out ./.plan
 terraform apply ./.plan
fi 


CICD_WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw provider_full_id_cicd)
CICD_SERVICE_ACCOUNT=$(terraform output -raw github_service_account_cicd)
STATE_BUCKET=$(terraform output -raw STATE_BUCKET)
DEV_PROJECT_ID=$(terraform output -raw dev_project_id)
DEV_PROJECT_NUMBER=$(terraform output -raw dev_project_number)  

cat <<EOF > .env
CICD_WORKLOAD_IDENTITY_PROVIDER: $CICD_WORKLOAD_IDENTITY_PROVIDER
CICD_SERVICE_ACCOUNT: $CICD_SERVICE_ACCOUNT
STATE_BUCKET: $STATE_BUCKET
DEV_PROJECT_ID: $DEV_PROJECT_ID
DEV_PROJECT_NUMBER: $DEV_PROJECT_NUMBER
EOF

# Set github secrets for iac
gh secret set -f .env

echo "Running cloud run deployment"
gcloud run deploy $resource_name \
--image us-docker.pkg.dev/cloudrun/container/hello \
--allow-unauthenticated \
--ingress all \
--region europe-west2 \
--project $dev_project_id

# Remove no longer needed files
echo "Remove Terraform state lock and State file"
rm .terraform.lock.hcl
rm -rf .terraform
rm .plan
rm .env

# Bootstrap is now complete
echo "The bootstrap is now complete."
echo "Please proceed to populate notifacation channels"
echo "Has the above been completed (y/n)"
read notifacation_done

if [[ $notifacation_done == "y" ]]; then 
 echo "Please continue"
fi 

if [[ $notifacation_done == "n" ]]; then 
 echo "This must be completed before proceeding"
fi 

# Change dir to iac
cd ../iac

export TF_VAR_project_id=$dev_project_id
export TF_VAR_project_number=$dev_project_number
echo "Terraform init"
terraform init -backend-config="bucket=${state_bucket}-${cicd_project_id}" -backend-config="prefix=dev"

echo "Terraform plan"
terraform plan -out ./.plan

echo "Please review the Terraform plan"

echo "Is the plan correct? (y/n)"
read terrafrom_plan_response

if [[ $terrafrom_plan_response == "y" ]]; then 
 echo "Terrafrom Apply will now run!"
fi 

echo "Terraform apply"
terraform apply ./.plan

WORKLOAD_IDENTITY_PROVIDER=$(terraform output -raw provider_full_id_dev)
SERVICE_ACCOUNT=$(terraform output -raw github_service_account_dev)

cat <<EOF > .env
DEV_WORKLOAD_IDENTITY_PROVIDER: $DEV_WORKLOAD_IDENTITY_PROVIDER
DEV_SERVICE_ACCOUNT: $DEV_SERVICE_ACCOUNT
RESOURCE_CLOUD_RUN: $resource_name
EOF

# Set github secrets for app
gh secret set -f .env

# Remove no longer needed files
echo "Remove Terraform state lock and State file"
rm .terraform.lock.hcl
rm -rf .terraform
rm .plan
rm .env