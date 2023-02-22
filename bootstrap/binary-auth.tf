##### Binary Authorization Attestor Kms
resource "random_id" "suffix" {
  byte_length = 2
}

resource "google_binary_authorization_attestor" "attestor" {
  project = local.cicd_project_id
  name    = "attestor-${local.cicd_project_id}"
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
    google_project_service.enable_artifact_apis
  ]
}

data "google_kms_crypto_key_version" "version" {
  crypto_key = google_kms_crypto_key.asymmetric-sign-key.id
  version = 1
}

resource "google_container_analysis_note" "note" {
  project = local.cicd_project_id
  name    = "attestor-note"
  attestation_authority {
    hint {
      human_readable_name = "Attestor Note"
    }
  }
  depends_on = [
    google_project_service.enable_artifact_apis
  ]
}

resource "google_kms_crypto_key" "asymmetric-sign-key" {
  name     = "crypto-key-binauth-${local.cicd_project_id}"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm = "EC_SIGN_P256_SHA256"
  }

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [
    google_project_service.enable_artifact_apis
  ]
}

resource "google_kms_key_ring" "keyring" {
  project  = local.cicd_project_id
  name     = "binauth-keyring-${local.cicd_project_id}"
  location = local.default_region
  depends_on = [
    google_project_service.enable_artifact_apis
  ]
}