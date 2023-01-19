terraform {
  backend "gcs" {
    bucket = "bkt-appdev-cm-cicd"
    prefix = "bootstrap"
  }
}