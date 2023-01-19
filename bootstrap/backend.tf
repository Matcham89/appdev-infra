terraform {
  backend "gcs" {
    bucket = "bkt-my-project-54162-cicd"
    prefix = "bootstrap"
  }
}