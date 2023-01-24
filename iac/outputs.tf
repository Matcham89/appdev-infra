output "GOOGLE_CLOUD_PROJECT" {
  value = data.google_project.project_id.project_id
}

# output "BQ_DATASET" {
#   value = google_bigquery_dataset.dataset.dataset_id
# }

# output "BQ_TABLE" {
#   value = google_bigquery_table.raw_sheet.table_id
# }

output "PASSWORD_SECRET" {
  value = google_secret_manager_secret.password.secret_id
}

output "KEYRING_NAME" {
  value = google_kms_key_ring.keyring.name
}

output "KEY_NAME" {
  value = google_kms_crypto_key.asymmetric-sign-key.name
}

output "KEYRING_LOCATION" {
  value = google_kms_key_ring.keyring.location
}

output "KEY_VERSION" {
  value = data.google_kms_crypto_key_version.version.version
}

output "ARTIFACT_REPOSTIORY_NAME" {
  value = data.google_artifact_registry_repository.cicd_repo.name
}

output "ATTESTOR_NAME" {
  value = google_binary_authorization_attestor.attestor.name
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

# output "QUEUE_NAME" {
#   value = google_cloud_tasks_queue.queue.name
# }

output "TARGET_BUCKET" {
  value = google_storage_bucket.gcs.name
}
