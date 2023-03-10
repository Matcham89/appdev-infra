data "google_artifact_registry_repository" "cicd_repo" {
  location      = local.default_region
  project       = local.cicd_project_id
  repository_id = local.artifact_repo_id
}



resource "google_binary_authorization_policy" "policy" {
  project = var.project_id
  # admission_whitelist_patterns {
  #   name_pattern = "europe-west2-docker.pkg.dev/${data.google_artifact_registry_repository.cicd_repo.project}/${data.google_artifact_registry_repository.cicd_repo.repository_id}/*"
  # }

  default_admission_rule {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [local.attestor_name]
  }
}

# data "google_kms_key_ring" "my_key_ring" {
#   project  = local.cicd_project_id
#   name     = local.keyring_name
#   location = local.default_region
# }

# data "google_kms_crypto_key_version" "my_crypto_key_version" {
#   crypto_key = "${local.cicd_project_id}/${local.default_region}/${local.keyring_name}/${local.key_name}"
#   version    = "1"
# }
