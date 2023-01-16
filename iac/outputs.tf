output "GOOGLE_CLOUD_PROJECT" {
  value = data.google_project.project_id.project_id
}

output "BQ_YOUGOV_DATASET" {
  value = google_bigquery_dataset.yougov_dataset.dataset_id
}

output "BQ_YOUGOV_TABLE" {
  value = google_bigquery_table.CSV.table_id
}

output "YOUGOV_QUEUE_NAME" {
  value = google_cloud_tasks_queue.yougov_queue.name
}

output "YOUGOV_USERNAME_SECRET" {
  value = google_secret_manager_secret.yougov_username.secret_id
}

output "YOUGOV_PASSWORD_SECRET" {
  value = google_secret_manager_secret.yougov_password.secret_id
}

output "KEYRING_NAME" {
  value = google_kms_key_ring.keyring.name
}

output "KEY_NAME" {
  value = google_kms_crypto_key.asymmetric-sign-key.name
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

output "CLOUD_TASKS_SA_EMAIL_YOUGOV" {
  value = google_service_account.sa_cr_yougov.email
}

output "CLOUD_TASKS_SA_EMAIL_NIELSEN" {
  value = google_service_account.sa_cr_nielsen.email
}

output "CLOUD_RUN_SA_EMAIL_WEBAPP" {
  value = google_service_account.sa_cr_webapp.email
}

output "MONGODB_CONNECTION_STRING" {
  value = google_secret_manager_secret.nielsen_mongo_connection_str.secret_id
}

output "NIELSEN_QUEUE_NAME" {
  value = google_cloud_tasks_queue.nielsen_queue.name
}
output "NIELSEN_TARGET_BUCKET" {
  value = google_storage_bucket.nielsen_gcs.name
}

output "WEBAPP_OKTA_CLIENTID" {
  value = google_secret_manager_secret.webapp_okta_clientid.secret_id
}

output "WEBAPP_OKTA_NEXTAUTH_SECRET" {
  value = google_secret_manager_secret.webapp_nextauth_secret.secret_id
}

output "WEBAPP_OKTA_CLIENTSECRET" {
  value = google_secret_manager_secret.webapp_okta_clientsecret.secret_id
}

output "WEBAPP_OKTA_ISSUER" {
  value = google_secret_manager_secret.webapp_okta_issuer.secret_id
}

output "WEBAPP_DATABASE_URL" {
  value = google_secret_manager_secret.webapp_database_url.secret_id
}
