# Enable this provider after configuring a gcp secret engine.
# provider "google" {
#   project = var.gcp_project
#   region  = var.gcp_region
#   # credentials = base64decode(data.vault_generic_secret.terraform.data["private_key_data"])
# 
#   # This should be used if need to wait the desired period until being enabled SA.
#   credentials = data.external.credentials.result["credentials"]
# }
# 
# data "vault_generic_secret" "terraform" {
#   path = "gcp/key/terraform"
# }
# 
# data "external" "credentials" {
#   program = ["./gcp-credentials.sh"]
# 
#   query = {
#     credentials = base64decode(data.vault_generic_secret.terraform.data["private_key_data"])
#   }
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
