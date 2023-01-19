terraform {
  backend "gcs" {
    bucket = "terraform-app-cicd-state"
    prefix = "bootstrap"
  }
}