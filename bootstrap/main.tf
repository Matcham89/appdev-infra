data "google_project" "dev_project" {
  project_id = local.bootstrap_config.dev_project_id
}


resource "google_project_service" "enable_artifact_apis" {
  project = local.bootstrap_config.cicd_project_id
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
  project = local.bootstrap_config.dev_project_id
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
  project       = local.bootstrap_config.cicd_project_id
  location      = local.bootstrap_config.default_region
  description   = "Artifact Registry to host the application"
  format        = "DOCKER"
  repository_id = local.bootstrap_config.image_repo_name

  depends_on = [
    google_project_service.enable_artifact_apis
  ]

}

