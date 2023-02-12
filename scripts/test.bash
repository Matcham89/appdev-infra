#!/bin/bash

cat <<EOF > backend.tf
terraform {
  backend "gcs" {
    bucket = "bkt-mlab-ui-cicd-tfstates"
    prefix = "bootstrap"
  }
}
EOF
