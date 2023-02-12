output "GOOGLE_CLOUD_PROJECT" {
  value = data.google_project.project_id.project_id
}

output "KEYRING_NAME" {
  value = local.keyring_name
}

output "KEY_NAME" {
  value = local.key_name
}

output "KEYRING_LOCATION" {
  value = local.keyring_location
}

output "KEY_VERSION" {
  value = local.key_version
}

output "ARTIFACT_REPOSTIORY_NAME" {
  value = data.google_artifact_registry_repository.cicd_repo.name
}

output "ATTESTOR_NAME" {
  value = local.attestor_name
}

output "REPO_PROJECT_ID" {
  value = data.google_artifact_registry_repository.cicd_repo.project
}

output "RESOURCE_PROJECT" {
  value = data.google_project.project_id.project_id
}

output "REGION" {
  value = local.default_region
}

output "CLOUD_TASKS_SA_EMAIL" {
  value = google_service_account.sa_cr.email
}

output "CLOUD_RUN_SA_EMAIL" {
  value = google_service_account.sa_cr.email
}

output "RESOURCE_CLOUD_RUN" {
  value = data.google_cloud_run_service.cr_data.name
}

output "CONNECTOR_NAME" {
  value = google_vpc_access_connector.connector.name
}

output "TARGET_BUCKET" {
  value = google_storage_bucket.gcs.name
}

