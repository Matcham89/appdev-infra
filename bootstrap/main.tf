locals {
  default_region   = "europe-west2"
  repo_name        = "mcm-createlift-infra"
  dev_repo_branch  = "^${var.dev_project_id}$"
  uat_repo_branch  = "^${var.uat_project_id}$"
  test_repo_branch = "^${var.test_project_id}$"
}


data "google_project" "dev_project" {
  project_id = var.dev_project_id
}

data "google_project" "test_project" {
  project_id = var.test_project_id
}

data "google_project" "uat_project" {
  project_id = var.uat_project_id
}




resource "google_project_service" "enable_artifact_apis" {
  project = var.cicd_project_id
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "binaryauthorization.googleapis.com",
    "containerscanning.googleapis.com",
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}


resource "google_project_service" "enable_artifact_apis_dev" {
  project = var.dev_project_id
  for_each = toset([
   "run.googleapis.com"
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}


resource "google_project_service" "enable_artifact_apis_test" {
  project = var.test_project_id
  for_each = toset([
   "run.googleapis.com"
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}


resource "google_project_service" "enable_artifact_apis_uat" {
  project = var.uat_project_id
  for_each = toset([
   "run.googleapis.com"
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}

###################################################
########### Artifact Registry Creation ############
###################################################




resource "google_artifact_registry_repository" "artifact_registry" {
  project       = var.cicd_project_id
  location      = local.default_region
  description   = var.description
  format        = var.af_format
  repository_id = var.image_repo_name

  depends_on = [
    google_project_service.enable_artifact_apis
  ]

}

