terraform {
  backend "gcs" {
    bucket = "bkt-papaj-01-papaj-cicd-01"
    prefix = "bootstrap"
  }
}
