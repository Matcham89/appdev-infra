output "STATE_BUCKET" {
  value = local.state_bucket
}

output "default_region" {
  value       = local.default_region
  description = "region of the project"
  sensitive   = true
}

output "google_artifact_registry_repository" {
  value     = google_artifact_registry_repository.artifact_registry.id
  sensitive = true
}

output "google_artifact_registry_repository_name" {
  value     = google_artifact_registry_repository.artifact_registry.name
  sensitive = true
}

output "google_artifact_registry_repository_project_id" {
  value     = google_artifact_registry_repository.artifact_registry.project
  sensitive = true
}


output "google_artifact_registry_repository_project_region" {
  value     = google_artifact_registry_repository.artifact_registry.location
  sensitive = true
}

output "dev_project_id" {
  value       = local.bootstrap_config.dev_project_id
  description = "The ID of the Dev project"
}

output "dev_project_number" {
  value       = data.google_project.dev_project.number
  description = "The Number of the DEV project"
}

output "cicd_project_id" {
  value       = local.bootstrap_config.cicd_project_id
  description = "The ID of the cicd project"
}


# output "Github_Pool_id_cicd" {
#   value = google_iam_workload_identity_pool.github_pool_cicd.workload_identity_pool_id
# }

# output "Github_Pool_full_id_cicd" {
#   value = google_iam_workload_identity_pool.github_pool_cicd.id
# }

# output "provider_id_cicd" {
#   value = google_iam_workload_identity_pool_provider.github_provider_cicd.workload_identity_pool_provider_id
# }



# output "Github_Pool_id_dev" {
#   value = google_iam_workload_identity_pool.github_pool_dev.workload_identity_pool_id
# }

# output "Github_Pool_full_id_dev" {
#   value = google_iam_workload_identity_pool.github_pool_dev.id
# }

# output "provider_id_dev" {
#   value = google_iam_workload_identity_pool_provider.github_provider_dev.workload_identity_pool_provider_id
# }

output "provider_full_id_cicd" {
  value       = google_iam_workload_identity_pool_provider.github_provider_cicd.name
  description = "Github Actions Provider for IaC deployment"
}

output "github_service_account_cicd" {
  value = google_service_account.sa_github_cicd.email
}

output "provider_full_id_dev" {
  value       = google_iam_workload_identity_pool_provider.github_provider_dev.name
  description = "Github Actions Provider for DEV App deployment"
}
output "github_service_account_dev" {
  value       = google_service_account.sa_github_dev.email
  description = "Github Actions Servive Account for DEV App deployment"
}

output "github_repo_binding_cicd" {
  value = google_service_account_iam_binding.github_account_binding_cicd.members
}

output "github_repo_binding_dev" {
  value = google_service_account_iam_binding.github_account_binding_dev.members
}

output "attestor_name" {
  value = google_binary_authorization_attestor.attestor.id
}

output "keyring_name" {
  value = google_kms_key_ring.keyring.name
}

output "key_name" {
  value = google_kms_crypto_key.asymmetric-sign-key.name
}

output "keyring_location" {
  value = google_kms_key_ring.keyring.location
}

output "key_version" {
  value = data.google_kms_crypto_key_version.version.version
}

output "monitor_alerts_email" {
  value = local.monitor_alerts_email
}

output "resource_name" {
  value = local.resource_name
}
