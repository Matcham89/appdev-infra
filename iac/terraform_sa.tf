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
