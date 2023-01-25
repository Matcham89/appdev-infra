
data "google_project" "project_id" {
  project_id = var.project_id
}


data "google_cloud_run_service" "cr_data" {
  project  = var.project_id
  location = local.default_region
  name     = "cr-${var.project_id}"

}











