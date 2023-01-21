resource "vault_gcp_secret_backend" "gcp" {}

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
