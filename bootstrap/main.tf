data "google_project" "dev_project" {
  project_id = local.bootstrap_config.dev_project_id
}


resource "google_project_service" "enable_artifact_apis" {
  project = local.cicd_project_id
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "binaryauthorization.googleapis.com",
    "containerscanning.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}


resource "google_project_service" "enable_artifact_apis_dev" {
  project = local.dev_project_id
  for_each = toset([
    "run.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtasks.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "binaryauthorization.googleapis.com"
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}


###################################################
########### Artifact Registry Creation ############
###################################################




resource "google_artifact_registry_repository" "artifact_registry" {
  project       = local.bootstrap_config.cicd_project_id
  location      = local.bootstrap_config.default_region
  description   = "Artifact Registry to host the application"
  format        = "DOCKER"
  repository_id = local.bootstrap_config.image_repo_name

  depends_on = [
    google_project_service.enable_artifact_apis
  ]

}

