terraform {
  backend "gcs" {
    bucket = "bkt-sao-89-sao-cicd-89"
    prefix = "bootstrap"
  }
}
