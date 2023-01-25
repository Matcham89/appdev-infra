
###################################################
###################### GCS ########################
###################################################


resource "google_storage_bucket" "gcs" {
  project                     = var.project_id
  name                        = "bkt-${var.project_id}-gcs"
  location                    = local.default_region
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket_iam_member" "gcs_member" {
  bucket = google_storage_bucket.gcs.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.sa_cr.email}"
}
