
####################################################
######### Cloud Scheduler Service Account ##########
####################################################

# resource "google_service_account" "sa_scheduler" {
#   project      = var.project_id
#   account_id   = "sa-scheduler"
#   description  = "Cloud Scheduler service account used to trigger scheduled Cloud Run jobs."
#   display_name = "sa-scheduler"

#   # Use an explicit depends_on clause to wait until API is enabled
# }


# # Basic roles required by the Scheduler service
# resource "google_project_iam_member" "scheduler_access" {
#   project = var.project_id
#   member  = google_service_account.sa_scheduler.member
#   role    = "roles/run.invoker"
# }



# # Allow the Terraform SA to 'actAs' the cloud scheduler service account in order to deploy a schedule
# resource "google_service_account_iam_member" "actas_cloud_scheduler_sa" {
#   service_account_id = google_service_account.sa_scheduler.id
#   role               = "roles/iam.serviceAccountUser"
#   member             = "serviceAccount:${google_service_account.sa_terraform.email}"
# }



####################################################
################# Cloud Scheduler ##################
####################################################

# data "google_cloud_run_service" "cr_data" {
#   project  = var.project_id
#   location = local.default_region
#   name     = "cr-${var.project_id}"
# }


# resource "google_cloud_scheduler_job" "cs" {
#   project     = var.project_id
#   region      = local.default_region
#   name        = "data-collection-${random_id.suffix.hex}"
#   description = "Collect data from source"
#   schedule    = "30 7 14,28 * *"
#   time_zone   = "Europe/London"
#   depends_on = [
#     google_service_account.sa_scheduler
#   ]

#   retry_config {
#     min_backoff_duration = "5s"
#     max_backoff_duration = "3600s"
#     max_retry_duration   = "10s"
#     max_doublings        = 2
#     retry_count          = 3
#   }


#   http_target {
#     http_method = "GET"
#     uri         = "${data.google_cloud_run_service.cr_data.status[0].url}/api/trigger/schedule"
#     oidc_token {
#       service_account_email = google_service_account.sa_scheduler.email
#     }
#   }
# }