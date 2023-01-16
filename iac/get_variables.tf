# Load the config yaml from the root of the repo
locals {
  application_config = yamldecode(file("./application_config.yaml"))
}

# Load individual values from the config yaml
locals {
  cr_webapp  = local.application_config.cr_webapp
  cr_nielsen = local.application_config.cr_nielsen
  cr_yougov  = local.application_config.cr_yougov
  cr_did     = local.application_config.cr_did

  runtime_nielsen = local.application_config.runtime_nielsen
  runtime_webapp  = local.application_config.runtime_webapp
  runtime_yougov  = local.application_config.runtime_yougov
  runtime_did     = local.application_config.runtime_did

  entrypoint_nielsen = local.application_config.entrypoint_nielsen
  entrypoint_webapp  = local.application_config.entrypoint_webapp
  entrypoint_yougov  = local.application_config.entrypoint_yougov
  entrypoint_did     = local.application_config.entrypoint_did


  webapp_image  = local.application_config.webapp_image
  yougov_image  = local.application_config.yougov_image
  nielsen_image = local.application_config.nielsen_image
  did_image     = local.application_config.did_image
}
