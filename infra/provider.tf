provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = base64decode(data.vault_generic_secret.terraform.data["private_key_data"])

  # This should be used if need to wait the desired period until being enabled SA.
  # credentials = data.external.credentials.result["credentials"]
}

provider "google-beta" {
  project     = var.gcp_project
  region      = var.gcp_region
  credentials = base64decode(data.vault_generic_secret.terraform.data["private_key_data"])
}

data "vault_generic_secret" "terraform" {
  path = "gcp/key/terraform"
}

# data "external" "credentials" {
#   program = ["./gcp-credentials.sh", base64decode(data.vault_generic_secret.terraform.data["private_key_data"]), "5"]
# }

provider "vault" {
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

# provider "waypoint" {
#   token = var.waypoint_token
# }
