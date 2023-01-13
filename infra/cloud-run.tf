# This is used for the first deployment as a default value.
# Regarding continuous delivery, it will be realized by Waypoint.
resource "google_cloud_run_service" "vault-server" {
  name     = "vault-server"
  location = var.gcp_region

  template {
    spec {
      container_concurrency = 80
      timeout_seconds       = 300
      service_account_name  = google_service_account.vault-server.email

      containers {
        image = "asia.gcr.io/knanao/vault:v1.12.2"
        args = [
          "server",
          "-config=/etc/vault/config.hcl",
        ]

        resources {
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }

        ports {
          container_port = 8200
        }

        env {
          name  = "GOOGLE_PROJECT"
          value = var.gcp_project
        }

        env {
          name  = "GOOGLE_STORAGE_BUCKET"
          value = google_storage_bucket.vault-data.name
        }

        env {
          name  = "SKIP_SETCAP"
          value = 1
        }

        volume_mounts {
          mount_path = "/etc/vault/config.hcl"
          name       = google_secret_manager_secret.vault-server-config.secret_id
        }
      }

      volumes {
        name = google_secret_manager_secret.vault-server-config.secret_id

        secret {
          secret_name = google_secret_manager_secret.vault-server-config.secret_id
        }
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"  = 1
        "autoscaling.knative.dev/minScale"  = 1
        "run.googleapis.com/cpu-throttling" = false
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      traffic,
      template,
      metadata,
      status,
    ]
  }
}

## NOTE: You should not make vault-server public before initilizing it.
resource "google_cloud_run_service_iam_binding" "noauth" {
  location = google_cloud_run_service.vault-server.location
  service  = google_cloud_run_service.vault-server.name
  role     = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}
