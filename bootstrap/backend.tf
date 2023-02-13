  terraform {
  backend "gcs" {
    bucket = "bkt-zizi-02-zizi-cicd-012"
    prefix = "bootstrap"
   }
  }
