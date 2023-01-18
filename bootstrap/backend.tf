terraform {
  backend "gcs" {
    bucket = "bkt-app-cicd-tfstate"
    prefix = "bootstrap"
  }
}