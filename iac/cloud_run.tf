



###################################################
###### Cloud Run yougov Service Account ##########
###################################################

resource "google_service_account" "sa_cr" {
  project      = var.project_id
  account_id   = "sa-cr"
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

resource "google_secret_manager_secret_iam_member" "sa_cr_un" {
  project   = google_secret_manager_secret.username.project
  secret_id = google_secret_manager_secret.username.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr.member
}


resource "google_secret_manager_secret_iam_member" "sa_cr_pw" {
  project   = google_secret_manager_secret.password.project
  secret_id = google_secret_manager_secret.password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr.member
}



###################################################
######## Cloud Run robot Service Account ##########
###################################################


resource "google_project_iam_member" "cloudrun_cicd_access" {
  project = local.cicd_project_id
  member  = "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
  role    = each.value

  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.admin"
  ])
}

