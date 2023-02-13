terraform {
  backend "gcs" {
    bucket = "bkt-banjo-89-banjo-cicd-89"
    prefix = "bootstrap"
  }
}
