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
