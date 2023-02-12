terraform {
  backend "gcs" {
    bucket = "chris-cicd-bkt-01-chris-cicd-company-01"
    prefix = "bootstrap"
  }
}
