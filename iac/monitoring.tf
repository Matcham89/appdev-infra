## Cloud Run Application SLO

module "slo_application" {
  source = "terraform-google-modules/slo/google//modules/slo-native"
  config = {
    project_id        = var.project_id
    service           = data.google_cloud_run_service.cr_data.service_id
    slo_id            = "cr-application-slo"
    display_name      = "90% of Cloud Run default service HTTP response latencies < 500ms over a day"
    goal              = 0.9
    calendar_period   = "DAY"
    type              = "basic_sli"
    method            = "latency"
    latency_threshold = "0.5s"
  }
}