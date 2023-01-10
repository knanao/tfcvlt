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
