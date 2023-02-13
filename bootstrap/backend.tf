terraform {
  backend "gcs" {
    bucket = "bkt-taco-012-taco-cicd-012"
    prefix = "bootstrap"
  }
}
