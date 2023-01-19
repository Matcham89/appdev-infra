terraform {
  backend "gcs" {
    bucket = "bkt-my-project-35513-cicd"
    prefix = "bootstrap"
  }
}