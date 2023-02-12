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
