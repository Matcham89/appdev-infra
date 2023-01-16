locals {
  bootstrap_config = yamldecode(file("../bootstrap_config.yaml"))
}

locals {
  cicd_project_id   = local.bootstrap_config.cicd_project_id
  dev_project_id = local.bootstrap_config.dev_project_id
  default_region = local.bootstrap_config.default_region
  image_repo_name = local.bootstrap_config.image_repo_name
  cicd_attribute_repository = local.bootstrap_config.cicd_attribute_repository
}

