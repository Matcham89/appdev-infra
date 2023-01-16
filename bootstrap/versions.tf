terraform {
  required_version = ">= 1.2.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.44.1"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.44.1"
    }
  }
}