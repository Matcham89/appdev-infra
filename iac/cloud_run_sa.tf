



###################################################
########### Cloud Run Service Account #############
###################################################

resource "google_service_account" "sa_cr" {
  project      = var.project_id
  account_id   = "sa-mlab-ui-${var.project_id}"
  display_name = "SA for the service on Cloud Run"
}

# Basic roles required by the Cloud Run service
resource "google_project_iam_member" "sa_cr_access" {
  project = var.project_id
  member  = google_service_account.sa_cr.member
  role    = each.value
  for_each = toset([
    "roles/logging.logWriter", "roles/monitoring.metricWriter",
    "roles/run.viewer", "roles/run.invoker",
    "roles/cloudtasks.enqueuer", "roles/cloudtasks.taskRunner", "roles/cloudtasks.taskDeleter",
    "roles/bigquery.jobUser", "roles/bigquery.dataEditor",
    "roles/iam.serviceAccountUser",
  ])
}

# resource "google_secret_manager_secret_iam_member" "sa_cr_un" {
#   project   = google_secret_manager_secret.username.project
#   secret_id = google_secret_manager_secret.username.secret_id
#   role      = "roles/secretmanager.secretAccessor"
#   member    = google_service_account.sa_cr.member
# }


# resource "google_secret_manager_secret_iam_member" "sa_cr_pw" {
#   project   = google_secret_manager_secret.password.project
#   secret_id = google_secret_manager_secret.password.secret_id
#   role      = "roles/secretmanager.secretAccessor"
#   member    = google_service_account.sa_cr.member
# }




###################################################
############## Robot Service Account ##############
###################################################


resource "google_project_iam_member" "cloudrun_cicd_access" {
  project = local.cicd_project_id
  member  = "serviceAccount:service-${data.google_project.project_id.number}@serverless-robot-prod.iam.gserviceaccount.com"
  role    = each.value

  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.admin"
  ])
  depends_on = [

  ]
}

resource "google_project_iam_member" "binary_cicd_access" {
  project = local.cicd_project_id
  member  = "serviceAccount:service-${data.google_project.project_id.number}@gcp-sa-binaryauthorization.iam.gserviceaccount.com"
  role    = each.value

  for_each = toset([
    "roles/binaryauthorization.policyViewer",
    "roles/binaryauthorization.attestorsVerifier",
  ])
}

resource "google_project_iam_member" "key_cicd_access" {
  project = local.cicd_project_id
  member  = "serviceAccount:service-${data.google_project.project_id.number}@compute-system.iam.gserviceaccount.com"
  role    = each.value

  for_each = toset([
    "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  ])
}