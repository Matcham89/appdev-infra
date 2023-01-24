terraform {
  backend "gcs" {
    bucket = "bkt-mlab-ui-cicd-tfstates"
    prefix = "bootstrap"
  }
}