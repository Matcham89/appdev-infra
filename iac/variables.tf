



variable "max_scale" {
  type        = string
  description = "value"
}

variable "min_scale" {
  type        = string
  description = "value"
}

variable "ip_white_list" {
  type        = list(any)
  description = "value"
}



# variable "bq_yougov_dataset" {
#   description = "The BigQuery dataset (in the 'GOOGLE_CLOUD_PROJECT' project) to write yougov data to"
#   type        = string
# }

# variable "bq_yougov_table" {
#   description = "The BigQuery table (in the 'BQ_YOUGOV_DATASET') to write Yougov data to"
#   type        = string
# }

variable "project_id" {
  type = string
}

variable "project_number" {
  type = string
}
