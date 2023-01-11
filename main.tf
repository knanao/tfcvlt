provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = var.gcp_credentials
}

resource "google_service_account" "vault-server" {
  account_id   = "vault-server"
  display_name = "vault-server"
}

resource "google_storage_bucket" "vault-data" {
  name     = "${var.gcp_project}-vault-data"
  location = var.gcp_region
}

resource "google_storage_bucket_iam_member" "vault-data" {
  bucket = google_storage_bucket.vault-data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_secret_manager_secret" "vault-server-config" {
  secret_id = "vault-server-config"

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "vault-server-config" {
  secret = google_secret_manager_secret.vault-server-config.id

  secret_data = file("./vault-server.hcl")
}

resource "google_secret_manager_secret_iam_member" "vault-server-config" {
  secret_id = google_secret_manager_secret.vault-server-config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_kms_key_ring" "vault-server" {
  name     = "vault-server"
  location = "global"
}

resource "google_kms_crypto_key" "vault-seal" {
  name     = "vault-seal"
  key_ring = google_kms_key_ring.vault-server.id
}

resource "google_kms_crypto_key_iam_member" "vault-seal" {
  crypto_key_id = google_kms_crypto_key.vault-seal.id
  role          = "roles/cloudkms.cryptoOperator"
  member        = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_cloud_run_service" "vault-server" {
  name     = "vault-server"
  location = var.gcp_region

  template {
    spec {
      container_concurrency = 80
      timeout_seconds       = 300
      service_account_name  = google_service_account.vault-server.email

      containers {
        image = "gcr.io/hightowerlabs/vault:1.7.1"

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
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.vault-server.location
  project  = google_cloud_run_service.vault-server.project
  service  = google_cloud_run_service.vault-server.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
