# ## Cloud Run Application SLO 

# resource "google_monitoring_notification_channel" "application_alerts" {
#   display_name = "admin"
#   project      = var.project_id
#   type         = "email"
#   labels = {
#     email_address = "${local.monitor_alerts_email}"
#   }

# }

# resource "google_monitoring_service" "cloud_run" {
#   project      = var.project_id
#   service_id   = "cloud-run-service"
#   display_name = "Cloud Run Service"

#   basic_service {
#     service_type = "CLOUD_RUN"
#     service_labels = {
#       service_name = local.resource_name
#       location     = local.default_region
#     }
#   }
# }


# resource "google_monitoring_slo" "latency_slo" {
#   project = var.project_id
#   service = google_monitoring_service.cloud_run.service_id

#   slo_id       = "${local.resource_name}-latency-slo"
#   display_name = "${local.resource_name} Latency SLO"

#   goal            = 0.9
#   calendar_period = "DAY"

#   basic_sli {
#     latency {
#       threshold = "5s"
#     }
#   }
# }

# resource "google_monitoring_slo" "availability_slo" {
#   project = var.project_id
#   service = google_monitoring_service.cloud_run.service_id

#   slo_id       = "${local.resource_name}-latency-slo"
#   display_name = "${local.resource_name} Latency SLO"

#   goal            = 0.9
#   calendar_period = "DAY"

#   basic_sli {
#     availability {
#       enabled = true
#     }
#   }
# }

# resource "google_monitoring_alert_policy" "burn_rate_latency_policy" {
#   depends_on   = [google_monitoring_slo.latency_slo]
#   project      = var.project_id
#   display_name = "${local.resource_name}-latency SLO burn rate"
#   combiner     = "OR"
#   conditions {
#     display_name = "10% burn rate on ${local.resource_name} Latency SLO"
#     condition_threshold {
#       filter     = "select_slo_burn_rate(\"projects/${var.project_number}/services/${google_monitoring_service.cloud_run.service_id}/serviceLevelObjectives/${local.resource_name}-latency-slo\", \"3600s\")"
#       duration   = "0s"
#       comparison = "COMPARISON_GT"
#       aggregations {
#         alignment_period     = "300s"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#       threshold_value = 10
#     }
#   }

#   documentation {
#     content   = <<EOT
# # Latency SLO Burn Rate

# ## Description

# There has been a 10% burn rate on the latency SLO error budget in the past 5 minutes on the [${local.resource_name}](https://console.cloud.google.com/run/detail/europe-west2/${local.resource_name}/metrics?project=${var.project_id}&supportedpurview=project)

# ## Analysis

# - Check [GCP CloudRun metrics](https://console.cloud.google.com/run/detail/europe-west2/${local.resource_name}/metrics?${var.project_id}&supportedpurview=project)
# - Check [GCP Logs](https://console.cloud.google.com/run/detail/europe-west2/${local.resource_name}/logs?project=${var.project_id}&supportedpurview=project)

# ## Resolution

# - Check the [GCP Alerting Dashboard](https://console.cloud.google.com/monitoring/alerting?project=${var.project_id}&supportedpurview=project) to see if incident is still open or has self-healed
# - If issue persists consider reverting to previous [CloudRun Revision](https://console.cloud.google.com/run/detail/europe-west2/${local.resource_name}/revisions?project=${var.project_id}&supportedpurview=project)

# EOT
#     mime_type = "text/markdown"
#   }
#   user_labels = {
#     severity = "warning"

#   }
#   notification_channels = ["${google_monitoring_notification_channel.application_alerts.display_name}"]
# }



# resource "google_monitoring_alert_policy" "burn_rate_availability_policy" {
#   depends_on   = [google_monitoring_slo.availability_slo]
#   project      = var.project_id
#   display_name = "${local.resource_name} availability SLO burn rate"
#   combiner     = "OR"
#   conditions {
#     display_name = "10% burn rate on ${local.resource_name} Availability SLO"
#     condition_threshold {
#       filter     = "select_slo_burn_rate(\"projects/${var.project_number}/services/${google_monitoring_service.cloud_run.service_id}/serviceLevelObjectives/${local.resource_name}-availability-slo\", \"3600s\")"
#       duration   = "0s"
#       comparison = "COMPARISON_GT"
#       aggregations {
#         alignment_period     = "300s"
#         cross_series_reducer = "REDUCE_NONE"
#       }
#       threshold_value = 10
#     }
#   }
#   documentation {
#     content   = <<EOT
# # Availability SLO Burn Rate

# ## Description

# There has been a 10% burn rate on the availability SLO error budget in the past 5 minutes on the [${local.resource_name}](https://console.cloud.google.com/run/detail/europe-west1/${local.resource_name}/metrics?project=${var.project_id}&supportedpurview=project)

# ## Analysis

# - Check [GCP CloudRun metrics](https://console.cloud.google.com/run/detail/europe-west1/${local.resource_name}/metrics?${var.project_id}&supportedpurview=project)
# - Check [GCP Logs](https://console.cloud.google.com/run/detail/europe-west1/${local.resource_name}/logs?project=${var.project_id}&supportedpurview=project)

# ## Resolution

# - Check the [GCP Alerting Dashboard](https://console.cloud.google.com/monitoring/alerting?project=${var.project_id}&supportedpurview=project) to see if incident is still open or has self-healed
# - If issue persists consider reverting to previous [CloudRun Revision](https://console.cloud.google.com/run/detail/europe-west1/${local.resource_name}/revisions?project=${var.project_id}&supportedpurview=project)

# EOT
#     mime_type = "text/markdown"
#   }
#   user_labels = {
#     service_name = local.resource_name
#   }
#   notification_channels = ["${google_monitoring_notification_channel.application_alerts.display_name}"]
# }
