#################################################
## CD Application Deployment Account TEST ENV ###
#################################################

resource "google_service_account" "sa_github_test" {
  project      = local.test_project_id
  account_id   = "sa-gha-${local.test_project_id}"
  display_name = "SA for the service Github actions"
}


resource "google_project_iam_member" "github_actions_access_test" {
  project = local.test_project_id
  member  = google_service_account.sa_github_test.member
  role    = each.value
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/containerregistry.ServiceAgent",
    "roles/artifactregistry.reader",
    "roles/artifactregistry.admin",
    "roles/viewer",
    "roles/run.viewer",
    "roles/binaryauthorization.attestorsAdmin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/cloudkms.cryptoOperator",
    "roles/containeranalysis.occurrences.editor",
    "roles/containeranalysis.notes.attacher",
    "roles/run.developer",
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator"

  ])
}


resource "google_project_iam_member" "github_actions_access_test_cicd" {
  project = local.cicd_project_id
  member  = google_service_account.sa_github_test.member
  role    = each.value
  for_each = toset([

    "roles/artifactregistry.admin",
    "roles/viewer",
  ])
}


resource "google_iam_workload_identity_pool" "github_pool_test" {
  project                   = local.test_project_id
  workload_identity_pool_id = "github-pl"
  display_name              = "Github actions authentication"
  description               = "Identity pool for automated delievery"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "github_provider_test" {
  project                            = local.test_project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool_test.workload_identity_pool_id
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
    google_iam_workload_identity_pool.github_pool_test
  ]
}

resource "google_service_account_iam_binding" "github_account_binding_test" {
  service_account_id = google_service_account.sa_github_test.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${google_service_account.sa_github_test.email}",
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool_test.name}/attribute.repository/${local.app_attribute_repository}"

  ]
}
