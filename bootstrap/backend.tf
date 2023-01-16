terraform {
  backend "gcs" {
    bucket = "bkt-createlift-cicd-tfstates"
    prefix = "bootstrap"
  }
}