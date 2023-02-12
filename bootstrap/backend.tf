  terraform {
  backend "gcs" {
    bucket = "bkt-yumyum-01-yumyum-cicd-01"
    prefix = "bootstrap"
   }
  }
