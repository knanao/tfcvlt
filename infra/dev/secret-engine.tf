resource "vault_gcp_secret_backend" "gcp" {
  default_lease_ttl_seconds = 60
  max_lease_ttl_seconds     = 120
}

resource "vault_gcp_secret_roleset" "terraform" {
  backend     = vault_gcp_secret_backend.gcp.path
  roleset     = "terraform"
  secret_type = "service_account_key"
  project     = var.gcp_project

  binding {
    resource = "//cloudresourcemanager.googleapis.com/projects/${var.gcp_project}"

    roles = [
      "roles/owner",
    ]
  }
}
