data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "bkt-taco-012-taco-cicd-012"
    prefix = "bootstrap"
  }
}

locals {
  default_region       = data.terraform_remote_state.bootstrap.outputs.default_region
  artifact_repo_id     = data.terraform_remote_state.bootstrap.outputs.google_artifact_registry_repository_name
  cicd_project_id      = data.terraform_remote_state.bootstrap.outputs.cicd_project_id
  monitor_alerts_email = data.terraform_remote_state.bootstrap.outputs.monitor_alerts_email
  attestor_name        = data.terraform_remote_state.bootstrap.outputs.attestor_name
  keyring_name         = data.terraform_remote_state.bootstrap.outputs.keyring_name
  key_name             = data.terraform_remote_state.bootstrap.outputs.key_name
  keyring_location     = data.terraform_remote_state.bootstrap.outputs.keyring_location
  resource_name        = data.terraform_remote_state.bootstrap.outputs.resource_name
}
