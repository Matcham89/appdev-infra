terraform {
  backend "gcs" {
    bucket = "bkt-voxis-012-voxis-cicd-012"
    prefix = "bootstrap"
  }
}
