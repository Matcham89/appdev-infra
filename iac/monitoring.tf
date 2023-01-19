## Cloud Run Application SLO latency


resource "google_monitoring_slo" "latency_slo" {
  project = var.project_id
  service = data.google_cloud_run_service.cr_data.id

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
  service = data.google_cloud_run_service.cr_data.id

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