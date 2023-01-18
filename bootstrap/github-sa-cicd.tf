#################################################
######### CD IAC WIF Account CICD ENV ###########
#################################################

resource "google_service_account" "sa_github_cicd" {
  project      = local.cicd_project_id
  account_id   = "sa-gha-${local.cicd_project_id}"
  display_name = "SA for the service Github actions"
}



resource "google_project_iam_member" "github_actions_access_cicd" {
  project = local.cicd_project_id
  member  = google_service_account.sa_github_cicd.member
  role    = each.value
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/browser",
    "roles/cloudbuild.serviceAgent",
    "roles/run.viewer",
    "roles/containeranalysis.notes.editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/iam.serviceAccountUser",
    "roles/storage.objectAdmin",

  ])
}

#################################################
######### CD IAC WIF Account Dev ENV ############
#################################################

resource "google_project_iam_member" "github_actions_access_cicd_dev" {
  project = local.dev_project_id
  member  = google_service_account.sa_github_cicd.member
  role    = each.value
  for_each = toset([
    "roles/bigquery.jobUser",
    "roles/cloudkms.admin",
    "roles/cloudkms.cryptoOperator",
    "roles/cloudscheduler.admin",
    "roles/cloudtasks.admin",
    "roles/compute.loadBalancerAdmin",
    "roles/compute.orgSecurityPolicyAdmin",
    "roles/containeranalysis.notes.editor",
    "roles/editor",
    "roles/resourcemanager.projectIamAdmin",
    "roles/secretmanager.admin",
    "roles/secretmanager.secretAccessor",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/binaryauthorization.attestorsAdmin",
    "roles/run.viewer",
    "roles/bigquery.dataEditor",
  ])
}


resource "google_iam_workload_identity_pool" "github_pool_cicd" {
  project                   = local.cicd_project_id
  workload_identity_pool_id = "github-action-pool-cicd"
  display_name              = "Github actions authentication"
  description               = "Identity pool for automated iac delievery"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github_provider_cicd" {
  project                            = local.cicd_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool_cicd.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-actions-provider"
  display_name                       = "Github actions provider"
  disabled                           = false
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  depends_on = [
    google_iam_workload_identity_pool.github_pool_cicd
  ]
}


resource "google_service_account_iam_binding" "github_account_binding_cicd" {
  service_account_id = google_service_account.sa_github_cicd.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.sa_github_cicd.email}",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool_cicd.name}/attribute.repository/${local.cicd_attribute_repository}",
  ]
}
