data "google_artifact_registry_repository" "cicd_repo" {
  location      = local.default_region
  project       = local.cicd_project_id
  repository_id = local.artifact_repo_id
}


resource "google_binary_authorization_policy" "policy" {
  project = var.project_id
  admission_whitelist_patterns {
    name_pattern = "europe-west2-docker.pkg.dev/${data.google_artifact_registry_repository.cicd_repo.project}/${data.google_artifact_registry_repository.cicd_repo.repository_id}/*"
  }

  default_admission_rule {
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [google_binary_authorization_attestor.attestor.name]
  }
  depends_on = [
    google_project_service.enable_project_apis
  ]
}

##### Binary Authorization Attestor Kms

resource "google_binary_authorization_attestor" "attestor" {
  project = var.project_id
  name    = "attestor-${var.project_id}"
  attestation_authority_note {
    note_reference = google_container_analysis_note.note.name
    public_keys {
      id = data.google_kms_crypto_key_version.version.id
      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.version.public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.version.public_key[0].algorithm
      }
    }
  }
  depends_on = [
    google_project_service.enable_project_apis
  ]
}

data "google_kms_crypto_key_version" "version" {
  crypto_key = google_kms_crypto_key.asymmetric-sign-key.id

  depends_on = [
    google_project_service.enable_project_apis
  ]
}

resource "google_container_analysis_note" "note" {
  project = var.project_id
  name    = "attestor-note-${var.project_id}"
  attestation_authority {
    hint {
      human_readable_name = "Attestor Note"
    }
  }
  depends_on = [
    google_project_service.enable_project_apis
  ]
}


resource "google_kms_crypto_key" "asymmetric-sign-key" {
  name     = "crypto-key-binauth-${var.project_id}-${random_id.suffix.hex}"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm = "EC_SIGN_P256_SHA256"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      version_template[0].algorithm
    ]
  }
  depends_on = [
    google_project_service.enable_project_apis
  ]
}

resource "google_kms_key_ring" "keyring" {
  project  = var.project_id
  name     = "binauth-keyring-${var.project_id}"
  location = local.default_region

  depends_on = [
    google_project_service.enable_project_apis
  ]
}
