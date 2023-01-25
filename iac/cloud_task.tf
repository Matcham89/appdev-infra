
#####################################################
################## Cloud Tasks  ####################
####################################################

# resource "random_id" "suffix" {
#   byte_length = 3
# }

# resource "google_cloud_tasks_queue" "queue" {
#   project  = var.project_id
#   name     = "queue-${random_id.suffix.hex}"
#   location = local.default_region

#   rate_limits {
#     max_concurrent_dispatches = 3
#     max_dispatches_per_second = 1
#   }

#   retry_config {
#     max_attempts       = 10
#     max_retry_duration = "4s"
#     max_backoff        = "3600s"
#     min_backoff        = "2s"
#     max_doublings      = 8
#   }
#   lifecycle {
#     create_before_destroy = true
#   }
#}

