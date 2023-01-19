# Overview

The following Terraform code will deploy multiple resources to support the hosting and delivery of applications.
 
This is designed to work in conjuction with appdev-application repo https://github.com/Matcham89/appdev-application

It will also create the required service accounts to run a CI/CD pipeline for the Application and the Infrastructure via GitHub Actions

<p>&nbsp;</p>

## Bootstrap

The bootstrap contains the following deployments and resources:

* API requirements

* Outputs to support main infrastructure and GitHub Actions CD

* Service accounts

* Artifact Registry 

* Google Cloud Storage Buckets for state-files

The bootstrap is deployed manually and only needs to be actioned once by an admin. If there is any requirement to update the bootstrap (services accounts/storage buckets) the manual process will need to be re-run.

<p>&nbsp;</p>


## IaC
The IaC contains all the required resources defined in the scope of work. These resources integrate with deployed resources generated via click-ops/GitHub actions (Cloud Run).

The deployed resources include:

* API requirements

* Service accounts

* Cloud Scheduler

* Cloud Tasks

* Google Cloud Storage Buckets

* Big Query Dataset

* Big Query Tables

* Secret Management

* Server-less Network End Group

* Cloud Armor 

<p>&nbsp;</p>


### Authentication

Service accounts for each project will be created during the bootstrap process. These service accounts will be created using Workload Identity Federation to authenticate with GitHub. The service account details will be stored in the GitHub repository as a “GitHub-secret”, this will isolate the number of engineers able to view the details.

Each environment will have its own service account to authenticate with GitHub, this is to reduce the blast radius should any credentials become victim to a security breach.

The advantage of the using Workload Identity Federation to authenticate is that the product team will be able to manage CD authentication directly without support from external technical teams.

<p>&nbsp;</p>

### Networking

Communication between the Web Application and the public internet will be routed through a Global Load Balancer working with a Network End Group. The security restriction on the Network End Group will be managed by Cloud Armor. 

<p>&nbsp;</p>

### Security

The WIF service account used for CD is created as part of the IaC with the best practise of least privilege as per Google recommendations. The WIF pool contains policy controls allowing the service account to connect to the relevant GitHub repository. The WIF service account information should be stored as a GithubSecret in the relevant repository by an administrator.

Each application has its own service account with the required permissions to carry out the task. The  service accounts are created as part of the IaC with the best practise of least privilege as per Google recommendations. No requirement to create service account keys. 

Each application requires credentials in order to run successfully. Secret resources are created via the IaC for every requirement on a per project basis. The value and version control of the secret will be controlled manually by an administrator.

<p>&nbsp;</p>

# Deployment

## New Branch

Create a new branch for your deployment eg. initial-deployment.

This will be required in order to trigger the Terraform Plan and Apply at a later stage without causing GitHub action errors.



### Prerequisites

Projects need to be created in the Google Cloud Console.

As a minimum a CICD (central host for the artifact registry and state files) and a DEV project need to be defined.

<p>&nbsp;</p>

Once at least two projects are created, in the CICD project a Google Cloud Storage bucket needs to be created. This bucket will host all of the state files for the Terraform.

Default settings are acceptable for this, however if you would like some HA select object versioning on the bucket options.

The bucket ID will need to be defined in the Terraform `backend.tf` for the BOOTSTRAP _AND_ the `remote_states.tf` for the IAC


appdev-infra/bootstrap/backend.tf
```bash
terraform {
  backend "gcs" {
    bucket = ""
    prefix = "bootstrap"
  }
}
```

<p>&nbsp;</p>

appdev-infra/iac/remote_states.tf
```bash
data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = ""
    prefix = "bootstrap"
  }
}

```

<p>&nbsp;</p>



Populate `bootstrap_config.yaml` with the required details

* CICD project - _This will host the artifact registry and appplications images. It will also hold the state files_

* DEV project - _This is the developement project_

```bash
# CICD Project ID
cicd_project_id: 

# DEV Project ID
dev_project_id: 

# Default Region
default_region:

# Name of the Artifact Registry
image_repo_name:

# Name of the Repo for the IaC
# Format "Owner/Repo Name"
cicd_attribute_repository:

# Name of the Repo for the Application
# Format "Owner/Repo Name"
app_attribute_repository: 
```

<p>&nbsp;</p>

### Connect to google cloud
```bash
 gcloud auth application-default login
```

<p>&nbsp;</p>




### Bootstrap


```bash
cd ./bootstrap/
terraform init
terraform plan -out ./.plan
terraform apply ./.plan
```

<p>&nbsp;</p>



### Deploy Cloud Run

For the IaC to deploy, Cloud Run resources must exsist in the project you are going to deploy to.

This is due to `data` dependencies defined in the Terraform code.

Run the below command to create a Cloud Run resource with some basic options. (The Image Name must match the name in the IAC Terraform code `main.tf` line 140)

<p>&nbsp;</p>

```bash
export PROJECT=<NAME OF DEV PROJECT>
gcloud run deploy appdev-application-test --image us-docker.pkg.dev/cloudrun/container/hello --allow-unauthenticated --ingress internal-and-cloud-load-balancing --region europe-west2 --project $PROJECT
```

<p>&nbsp;</p>


## IaC deployment with GitHub Actions

### GitHub Secretes

Once the bootstrap is complete, the following details need to be updated to GitHub secrets for both IAC CD worflow's and for the Application workflow in `appdev-application`:

<p>&nbsp;</p>


#### IAC CD worflow

* SERVICE_ACCOUNT  _(sa-gha-appdev-cm-cicd@appdev-cm-cicd.iam.gserviceaccount.com)_

* WORKLOAD_IDENTITY_PROVIDER _(projects/37532543929/locations/global/workloadIdentityPools/github-action-pool-cicd/providers/github-actions-provider)_

* BUCKET_PREFIX _(dev)_

* DEV_PROJECT_NUMBER _(37532543929)_

* DEV_PROJECT_ID _(appdev-cm-dev)_

<p>&nbsp;</p>


#### Application CD worflow

* BUCKET_PREFIX _(dev)_

* DEV_SERVICE_ACCOUNT  _(sa-gha-appdev-cm-dev@appdev-cm-dev.iam.gserviceaccount.com)_

* DEV_WORKLOAD_IDENTITY_PROVIDER _(projects/37532543929/locations/global/workloadIdentityPools/github-action-pool-dev/providers/github-actions-provider)_

* DEV_PROJECT_NUMBER _(37532543929)_

* DEV_PROJECT_ID _(appdev-cm-dev)_

<p>&nbsp;</p>


The details can be found in the outputs from the bootstrap.

<p>&nbsp;</p>

Each workflow references the required GitHub Secrets, so the variable as the same format as the workflow:

DEV_SERVICE_ACCOUNT = ${{ secrets.DEV_SERVICE_ACCOUNT }}

<p>&nbsp;</p>

Once all the secrets are populated, create a Pull Request into `main` to trigger the Terraform Plan.

_make sure you have removed the .terraform and state lock from `bootstrap` before commiting your changes_

When that has been successful, approve the merge to trigger the Terraform Apply.

<p>&nbsp;</p>

For authentication into Google Cloud the GitHub actions workflow uses `google-github-actions/auth@v0`

 https://github.com/google-github-actions/auth

 <p>&nbsp;</p>

### Trigger a GitHub Action

`main` = Development environment.

In order for the CD workflow to deploy the IaC, a feature branch must be created off of `main`.

The feature branch then requires a `Pull Request` to be merged into `main`, this will produce a `Terraform Plan` in the GitHub actions.

Once the plan has been reviewed and approved, the `Pull Request` can be `Merged`. This will then produce a `Terraform Apply`.

The flow of promotion

| Root  | Action  | Target |
| :------------ |:---------------:| -----:|
| feature branch      | Pull Request | main |
| feature branch      | Merge        | main |

 <p>&nbsp;</p>


| Root  | Action  | Target |
| :------------ |:------:| -----:|
| main | Pull Request        | test |
| main | Merge        | test |

 <p>&nbsp;</p>

| Root  | Action  | Target |
| :------------ |:------:| -----:|
| test | Pull Request        | prod |
| test | Merge        | prod |

 <p>&nbsp;</p>


### Environment Preparation

The workflow installs the following tools in order to run the CD:

| Purpose  | Information |
| ------------- | ------------- |
| Authenticate with Google Cloud | https://github.com/google-github-actions/auth|
| Install Terraform  | https://github.com/hashicorp/setup-terraform |
| Use gcloud commands  | https://github.com/google-github-actions/setup-gcloud |
