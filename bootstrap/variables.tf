# variable "project_id" {
#   type = string

# }

variable "image_repo_name" {
  type        = string
  description = "value"
  default     = "ar-mcm-createlift"
}

variable "description" {
  type    = string
  default = "Artifact Registry to host the application"
}

variable "af_format" {
  type    = string
  default = "DOCKER"
}

variable "cicd_project_id" {
  type        = string
  default     = "createlift-cicd"
  description = "The ID of the CICD project that houses the pipeline"
}

variable "dev_project_id" {
  type        = string
  default     = "createlift-dev1"
  description = "The ID of the Development project"
}

variable "test_project_id" {
  type        = string
  default     = "createlift-test" ## currently set to "DEV" for developement purposes
  description = "The ID of the Test project"
}

variable "uat_project_id" {
  type        = string
  default     = "createlift-uat"
  description = "The ID of the UAT project"
}

