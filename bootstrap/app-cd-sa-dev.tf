#################################################
### CD Application Deployment Account Dev ENV ###
#################################################

resource "google_service_account" "sa_github_dev" {
  project      = local.dev_project_id
  account_id   = "sa-gha-${local.dev_project_id}"
  display_name = "SA for the service Github actions"
}


resource "google_project_iam_member" "github_actions_access_dev" {
  project = local.dev_project_id
  member  = google_service_account.sa_github_dev.member
  role    = each.value
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/containerregistry.ServiceAgent",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.admin",
    "roles/viewer",
    "roles/run.invoker",
    "roles/run.viewer",
    "roles/binaryauthorization.attestorsAdmin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/cloudkms.cryptoOperator",
    "roles/containeranalysis.occurrences.editor",
    "roles/containeranalysis.notes.attacher",
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/iam.serviceAccountTokenCreator",
    "roles/binaryauthorization.attestorsVerifier",
  ])
}


resource "google_project_iam_member" "github_actions_access_dev_cicd" {
  project = local.cicd_project_id
  member  = google_service_account.sa_github_dev.member
  role    = each.value
  for_each = toset([

    "roles/artifactregistry.admin",
    "roles/viewer",
    "roles/cloudkms.cryptoOperator",
    "roles/containeranalysis.occurrences.editor",
    "roles/containeranalysis.notes.attacher",
    "roles/binaryauthorization.attestorsVerifier"
  ])
}


resource "google_iam_workload_identity_pool" "github_pool_dev" {
  project                   = local.dev_project_id
  workload_identity_pool_id = "github-pl"
  display_name              = "Github actions authentication"
  description               = "Identity pool for automated delievery"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github_provider_dev" {
  project                            = local.dev_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool_dev.workload_identity_pool_id
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
    google_iam_workload_identity_pool.github_pool_dev
  ]
}

resource "google_service_account_iam_binding" "github_account_binding_dev" {
  service_account_id = google_service_account.sa_github_dev.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.sa_github_dev.email}",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool_dev.name}/attribute.repository/${local.app_attribute_repository}"

  ]
  depends_on = [
    google_service_account.sa_github_dev
  ]
}
