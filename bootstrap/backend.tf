terraform {
  backend "gcs" {
    bucket = "bkt-keys-012-keys-cicd-012"
    prefix = "bootstrap"
  }
}
