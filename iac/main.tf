
data "google_project" "project_id" {
  project_id = var.project_id
}
# Enable needed services APIs
resource "google_project_service" "enable_project_apis" {
  project = var.project_id
  for_each = toset([
    "cloudkms.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "oslogin.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "cloudfunctions.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudscheduler.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudtasks.googleapis.com",
    "bigquerydatatransfer.googleapis.com",
    "binaryauthorization.googleapis.com"
  ])
  service                    = each.value
  disable_dependent_services = true

  disable_on_destroy = false
}




####################################################
########### Terraform Service Account ##############
####################################################

resource "google_service_account" "sa_terraform" {
  project      = var.project_id
  account_id   = "sa-terraform"
  description  = "Terraform service account used to build infrastructure."
  display_name = "sa-terraform"

  # Use an explicit depends_on clause to wait until API is enabled
}


# Basic roles required for Terraform service account
resource "google_project_iam_member" "terraform_access" {
  project = var.project_id
  for_each = toset([
    "roles/bigquery.jobUser",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoOperator",
    "roles/cloudscheduler.admin",
    "roles/cloudtasks.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.orgSecurityPolicyAdmin",
    "roles/containeranalysis.notes.editor",
    "roles/viewer",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/cloudtasks.taskDeleter",
    "roles/binaryauthorization.attestorsAdmin",
    "roles/run.viewer",
    "roles/bigquery.dataEditor",
  ])
  role   = each.value
  member = "serviceAccount:${google_service_account.sa_terraform.email}"
}


# Create service account key
resource "google_service_account_key" "sa_terraform_key" {
  service_account_id = google_service_account.sa_terraform.name
}

# Create secret for the service account key
resource "google_secret_manager_secret" "sa_terraform_key" {
  project   = var.project_id
  secret_id = "sms-tf-sa-key"

  replication {
    user_managed {
      replicas {
        location = local.default_region
      }
    }
  }
}


####################################################
######### Cloud Scheduler Service Account ##########
####################################################

resource "google_service_account" "sa_scheduler" {
  project      = var.project_id
  account_id   = "sa-scheduler"
  description  = "Cloud Scheduler service account used to trigger scheduled Cloud Run jobs."
  display_name = "sa-scheduler"

  # Use an explicit depends_on clause to wait until API is enabled
}


# Basic roles required by the Scheduler service
resource "google_project_iam_member" "scheduler_access" {
  project = var.project_id
  member  = google_service_account.sa_scheduler.member
  role    = "roles/run.invoker"
}



# Allow the Terraform SA to 'actAs' the cloud scheduler service account in order to deploy a schedule
resource "google_service_account_iam_member" "actas_cloud_scheduler_sa" {
  service_account_id = google_service_account.sa_scheduler.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.sa_terraform.email}"
}



####################################################
############# Cloud Scheduler YouGov ###############
####################################################

data "google_cloud_run_service" "cr_data" {
  project  = var.project_id
  location = local.default_region
  name     = "appdev-application-test"

}


resource "google_cloud_scheduler_job" "cs" {
  project     = var.project_id
  region      = local.default_region
  name        = "data-collection-${random_id.suffix.hex}"
  description = "Collect data from source"
  schedule    = "30 7 14,28 * *"
  time_zone   = "Europe/London"
  depends_on = [
    google_service_account.sa_scheduler
  ]

  retry_config {
    min_backoff_duration = "5s"
    max_backoff_duration = "3600s"
    max_retry_duration   = "10s"
    max_doublings        = 2
    retry_count          = 3
  }


  http_target {
    http_method = "GET"
    uri         = "${data.google_cloud_run_service.cr_data.status[0].url}/api/trigger/schedule"
    oidc_token {
      service_account_email = google_service_account.sa_scheduler.email
    }
  }
}


####################################################
############### Cloud Tasks Yougov #################
####################################################

resource "random_id" "suffix" {
  byte_length = 3
}

resource "google_cloud_tasks_queue" "queue" {
  project  = var.project_id
  name     = "queue-${random_id.suffix.hex}"
  location = local.default_region

  rate_limits {
    max_concurrent_dispatches = 3
    max_dispatches_per_second = 1
  }

  retry_config {
    max_attempts       = 10
    max_retry_duration = "4s"
    max_backoff        = "3600s"
    min_backoff        = "2s"
    max_doublings      = 8
  }
  lifecycle {
    create_before_destroy = true
  }
}




###################################################
################### YouGov GCS  ###################
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



###################################################
############### Big Query  #################
###################################################



resource "google_bigquery_dataset" "dataset" {
  project       = var.project_id
  dataset_id    = "raw"
  friendly_name = "aw"
  description   = "data set"
  location      = "EU"


  labels = {
    env = ""
  }
}

resource "google_bigquery_table" "CSV" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "raw-sheet"



  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = "default"
  }

  schema              = <<EOF
[
    {
        "name": "date",
        "type": "DATE",
        "mode": "REQUIRED"
      },
      {
        "name": "region",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "sector_id",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "brand_id",
        "type": "INTEGER",
        "mode": "REQUIRED"
      },
      {
        "name": "metric",
        "type": "STRING",
        "mode": "REQUIRED"
      },
      {
        "name": "sector_label",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The descriptive label for the sector_id"
      },
      {
        "name": "brand_label",
        "type": "STRING",
        "mode": "NULLABLE",
        "description": "The descriptive label for the brand_id"
      },
      {
        "name": "ingest_datetime",
        "type": "DATETIME",
        "mode": "REQUIRED",
        "description": "The datetime this record was actually fetched / written to BQ"
      },
      {
        "name": "query",
        "type": "STRING",
        "mode": "REQUIRED",
        "description": "The sub-query that generated this record"
      },
      {
        "name": "volume",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "score",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "positives",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "negatives",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "positives_neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      },
      {
        "name": "negatives_neutrals",
        "type": "STRING",
        "mode": "NULLABLE"
      }
  ]    
EOF
  deletion_protection = false # important
  depends_on = [
    google_bigquery_table.CSV
  ]
}



# }


locals {
  project = var.project_id
}


resource "google_bigquery_table" "query_table" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "data-view"


  view {
    use_legacy_sql = false
    query          = <<-EOF
  SELECT * except (rank)
  FROM (
    SELECT 
      *,
      rank() over (partition by tbl.date, tbl.region, tbl.sector_id, tbl.brand_id, tbl.metric, tbl.query order by tbl.ingest_datetime desc) as rank
    FROM `${local.project}.raw.raw-sheet` as tbl
  ) 
  WHERE 
    rank = 1 and score != ""
    EOF
  }

  deletion_protection = false # important
  depends_on = [
    google_bigquery_dataset.dataset
  ]
}



###################################################
########## Configuration Data Secret  #############
###################################################
resource "google_secret_manager_secret" "secret-basic" {
  project   = var.project_id
  secret_id = "sms-config-data-${var.project_id}"

  replication {
    user_managed {
      replicas {
        location = local.default_region
      }
    }
  }
}


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

