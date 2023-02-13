terraform {
  backend "gcs" {
    bucket = "bkt-jstest-01-jsteat-cicd-01"
    prefix = "bootstrap"
  }
}
