## Cloud Run Application SLO latency

resource "google_monitoring_custom_service" "cloud_run" {
  service_id = "cloudrun_service"
  display_name = "Service For Cloud Run"

  telemetry {
      resource_name = data.google_cloud_run_service.cr_data.id
  }
}


resource "google_monitoring_slo" "latency_slo" {
  project = var.project_id
  service = google_monitoring_custom_service.cloud_run.service_id

  slo_id       = "${data.google_cloud_run_service.cr_data.name}-latency-slo"
  display_name = "${data.google_cloud_run_service.cr_data.name} Latency SLO"

  goal            = 0.9
  calendar_period = "DAY"

  basic_sli {
    latency {
      threshold = "1s"
    }
  }
}

resource "google_monitoring_slo" "availability_slo" {
  project = var.project_id
  service = google_monitoring_custom_service.cloud_run.service_id

  slo_id       = "${data.google_cloud_run_service.cr_data.name}-availability-slo"
  display_name = "${data.google_cloud_run_service.cr_data.name} Availability SLO"

  goal            = 0.9
  calendar_period = "DAY"

  basic_sli {
    availability {
      enabled = true
    }
  }
}