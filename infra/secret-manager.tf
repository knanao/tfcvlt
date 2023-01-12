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
