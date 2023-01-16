



###################################################
###### Cloud Run yougov Service Account ##########
###################################################

resource "google_service_account" "sa_cr_yougov" {
  project      = var.project_id
  account_id   = "sa-cr-yougov"
  display_name = "SA for the yougov service on Cloud Run"
}

# Basic roles required by the Cloud Run service
resource "google_project_iam_member" "sa_cr_yougov_access" {
  project = var.project_id
  member  = google_service_account.sa_cr_yougov.member
  role    = each.value
  for_each = toset([
    "roles/logging.logWriter", "roles/monitoring.metricWriter",
    "roles/run.viewer", "roles/run.invoker",
    "roles/cloudtasks.enqueuer", "roles/cloudtasks.taskRunner", "roles/cloudtasks.taskDeleter",
    "roles/bigquery.jobUser", "roles/bigquery.dataEditor",
    "roles/iam.serviceAccountUser",
  ])
}

resource "google_secret_manager_secret_iam_member" "sa_cr_yougov_un" {
  project   = google_secret_manager_secret.yougov_username.project
  secret_id = google_secret_manager_secret.yougov_username.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_yougov.member
}


resource "google_secret_manager_secret_iam_member" "sa_cr_yougov_pw" {
  project   = google_secret_manager_secret.yougov_password.project
  secret_id = google_secret_manager_secret.yougov_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_yougov.member
}


###################################################
###### Cloud Run nielsen Service Account ##########
###################################################

resource "google_service_account" "sa_cr_nielsen" {
  project      = var.project_id
  account_id   = "sa-cr-nielsen"
  display_name = "SA for the nielsen service on Cloud Run"
}

# Basic roles required by the Cloud Run service
resource "google_project_iam_member" "sa_cr_nielsen_access" {
  project = var.project_id
  member  = google_service_account.sa_cr_nielsen.member
  role    = each.value
  for_each = toset([
    "roles/cloudfunctions.invoker",
    "roles/run.viewer",
    "roles/run.invoker",
    "roles/run.admin",
    "roles/cloudtasks.enqueuer", "roles/cloudtasks.viewer",
    "roles/logging.logWriter", "roles/monitoring.metricWriter",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin",
    "roles/viewer",
  ])
}

resource "google_secret_manager_secret_iam_member" "sa_cr_nielsen_mongo_connection_str" {
  project   = google_secret_manager_secret.nielsen_mongo_connection_str.project
  secret_id = google_secret_manager_secret.nielsen_mongo_connection_str.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_nielsen.member
}




###################################################
###### Cloud Run webapp Service Account ##########
###################################################

resource "google_service_account" "sa_cr_webapp" {
  project      = var.project_id
  account_id   = "sa-cr-webapp"
  display_name = "SA for the webapp service on Cloud Run"
}

# Basic roles required by the Cloud Run service
resource "google_project_iam_member" "sa_cr_webapp_access" {
  project = var.project_id
  member  = google_service_account.sa_cr_webapp.member
  role    = each.value
  for_each = toset([
    "roles/logging.logWriter", "roles/bigquery.jobUser", "roles/monitoring.metricWriter"
  ])
}

resource "google_secret_manager_secret_iam_member" "sa_cr_webapp_nextauth_secret" {
  project   = google_secret_manager_secret.webapp_nextauth_secret.project
  secret_id = google_secret_manager_secret.webapp_nextauth_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_webapp.member
}

resource "google_secret_manager_secret_iam_member" "sa_cr_webapp_okta_clientid" {
  project   = google_secret_manager_secret.webapp_okta_clientid.project
  secret_id = google_secret_manager_secret.webapp_okta_clientid.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_webapp.member
}

resource "google_secret_manager_secret_iam_member" "sa_cr_webapp_okta_clientsecret" {
  project   = google_secret_manager_secret.webapp_okta_clientsecret.project
  secret_id = google_secret_manager_secret.webapp_okta_clientsecret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_webapp.member
}

resource "google_secret_manager_secret_iam_member" "sa_cr_webapp_okta_issuer" {
  project   = google_secret_manager_secret.webapp_okta_issuer.project
  secret_id = google_secret_manager_secret.webapp_okta_issuer.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_webapp.member
}

resource "google_secret_manager_secret_iam_member" "sa_cr_webapp_database_url" {
  project   = google_secret_manager_secret.webapp_database_url.project
  secret_id = google_secret_manager_secret.webapp_database_url.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.sa_cr_webapp.member
}



###################################################
######## Cloud Run robot Service Account ##########
###################################################


resource "google_project_iam_member" "cloudrun_cicd_access" {
  project = "createlift-cicd"
  member  = "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
  role    = each.value

  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.admin"
  ])
}

