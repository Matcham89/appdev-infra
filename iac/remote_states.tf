data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "bkt-createlift-cicd-tfstates"
    prefix = "bootstrap"
  }
}

locals {
  default_region   = data.terraform_remote_state.bootstrap.outputs.default_region
  artifact_repo_id = data.terraform_remote_state.bootstrap.outputs.google_artifact_registry_repository_name
  cicd_project_id  = data.terraform_remote_state.bootstrap.outputs.cicd_project_id
}