# Overview

The following Terraform code will deploy multiple resources to support the hosting and delivery of applications.

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

### Hosted Services Controls

<p>&nbsp;</p>

The platform hosts the following executable’s:

* Web Portal (running on Cloud Run)

* Data Ingest (running on Cloud Run)

* Back-end API service (running on Cloud Run)

Cloud Run resources will use Google Cloud IAM for internal traffic. The Web Portal resource will sit behind a Network End Group using Cloud Armor for protection, the ingress traffic will be restricted to GB only. This can be amended by updating the Terraform.

The Cloud Run resources will be managed and deployed via the Application CD pipeline.

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



### Prerequisites

Projects need to be created in the Google Cloud Console

A Google Cloud Storage bucket must exist in the Google Cloud Console and be defined in the Terraform `backend.tf`

As a minimum a CICD (central host for the artifact registry and state files) and a DEV project need to be defined.

<p>&nbsp;</p>

### Connect to google cloud
```bash
 gcloud auth application-default login
```

<p>&nbsp;</p>

### Define project variables



`mcm-createlift-infra/bootstrap/variables`


* CICD project - _This will host the artifact registry and appplications images. It will also hold the state files_

* DEV project - _This is the developement project_

* TEST project - _This is the testing project_

* UAT project - _This is the UAT project, in this scenorio it is being treated as main_

<p>&nbsp;</p> 

### Deploy Cloud Run

For the IaC to deploy Cloud Run resources must exsist in the project you are going to deploy to

After connecting to Google Cloud, run the below code

```bash
export PROJECT=<NAME OF PROJECT>
gcloud run deploy cr-mcm-createlift-nielsen-data --image us-docker.pkg.dev/cloudrun/container/hello --no-allow-unauthenticated --region europe-west2 --project $PROJECT
gcloud run deploy cr-mcm-createlift-yougov-data --image us-docker.pkg.dev/cloudrun/container/hello --no-allow-unauthenticated --region europe-west2 --project $PROJECT
```


### Bootstrap


```bash
cd ./bootstrap/
terraform init
terraform plan -out ./.plan
terraform apply ./.plan
```

<p>&nbsp;</p>

## Github Actions Workflow

### Authentication

Once the bootstrap is complete, the following details need to be updated to both CD worflow's for the deployment:

`cd-iac-pr.yml(pullrequest)` 

`cd-iac-ps.yml(merge)`

* SERVICE_ACCOUNT

* WORKLOAD_IDENTITY_PROVIDER

* PROJECT_NUMBER

* PROJECT_ID

* BUCKET_PREFIX

The details can be found in the outputs from the bootstrap.

For authentication into Google Cloud the GitHub actions workflow uses `google-github-actions/auth@v0`

 https://github.com/google-github-actions/auth

 <p>&nbsp;</p>

### Trigger a GitHub Action

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
| test | Pull Request        | uat |
| test | Merge        | uat |

 <p>&nbsp;</p>


### Environment Preparation

The workflow installs the following tools in order to run the CD:

| Purpose  | Information |
| ------------- | ------------- |
| Authenticate with Google Cloud | https://github.com/google-github-actions/auth|
| Install Terraform  | https://github.com/hashicorp/setup-terraform |
| Use gcloud commands  | https://github.com/google-github-actions/setup-gcloud |
