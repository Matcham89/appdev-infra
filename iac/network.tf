

# #######################################################
# ############### Network End Group #####################
# #######################################################


# data "google_cloud_run_service" "cr_data" {
#   project  = var.project_id
#   location = local.default_region
#   name     = "cr-hello-world"

# }

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "neg-cloud-run-${random_id.suffix.hex}"
  network_endpoint_type = "SERVERLESS"
  project               = var.project_id
  region                = local.default_region
  cloud_run {
    service = data.google_cloud_run_service.cr_data.name
  }
}




# #######################################################
# ######## Serverless External Load Balancer ############
# #######################################################

# data "google_compute_ssl_certificate" "createlift-cert" {
#   project = var.project_id
#   name    = "application-certificate"
# }



resource "google_compute_address" "glb_static" {
  name    = "glb-static-ip-address"
  region  = local.default_region
  project = var.project_id
}

module "lb-http" {
  source  = "./modules/load-balancer"
  project = var.project_id
  name    = "lb-cloud-run-${random_id.suffix.hex}"

  # ssl                  = true
  # use_ssl_certificates = true
  # ssl_certificates     = ["${data.google_compute_ssl_certificate.createlift-cert.self_link}"]
  # https_redirect       = true

  address = google_compute_address.glb_static.address
  backends = {
    default = {
      description             = null
      enable_cdn              = false
      custom_request_headers  = null
      custom_response_headers = null
      security_policy         = google_compute_security_policy.policy.id


      log_config = {
        enable      = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Your serverless service should have a NEG created that's referenced here.
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }
    }
  }
}

resource "google_compute_security_policy" "policy" {
  project = var.project_id
  name    = "sec-policy-${random_id.suffix.hex}"
  type    = "CLOUD_ARMOR"

  # Reject all traffic that hasn't been whitelisted.
  rule {
    action   = "deny(403)"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]

      }
    }

    description = "Default rule, higher priority overrides it"
  }


  ## can add "#&& !inIpRange(origin.ip, '1.2.3.0/24')" to the below expression if required
  ## ref for region codes to allow https://en.wikipedia.org/wiki/ISO_3166-2
  rule {
    action   = "allow"
    priority = "1000"
    match {
      expr {
        expression = <<EOT
        origin.region_code == 'GB'  
        EOT
      }
    }
    description = "allow traffic from GB region"
  }
}
