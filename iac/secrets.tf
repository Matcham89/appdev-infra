
###################################################
############ username Secret  ##############
###################################################
resource "google_secret_manager_secret" "username" {
  project   = var.project_id
  secret_id = "sms-un-${var.project_id}"

  replication {
    user_managed {
      replicas {
        location = local.default_region
      }
    }
  }
}



###################################################
############ password Secret  ##############
###################################################
resource "google_secret_manager_secret" "password" {
  project   = var.project_id
  secret_id = "sms-pw-${var.project_id}"

  replication {
    user_managed {
      replicas {
        location = local.default_region
      }
    }
  }
}
