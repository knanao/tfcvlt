resource "google_service_account" "vault-server" {
  account_id   = "vault-server"
  display_name = "vault-server"
}

resource "google_project_iam_member" "service-account-admin" {
  project = var.gcp_project
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_project_iam_member" "service-account-key-admin" {
  project = var.gcp_project
  role    = "roles/iam.serviceAccountKeyAdmin"
  member  = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_project_iam_member" "project-iam-admin" {
  project = var.gcp_project
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.vault-server.email}"
}
