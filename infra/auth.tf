// resource "vault_auth_backend" "approle" {
//   type = "approle"
// }
// 
// resource "vault_approle_auth_backend_role" "terraform" {
//   backend   = vault_auth_backend.approle.path
//   role_name = "terraform"
//   token_policies = [
//     vault_policy.terraform.name,
//   ]
// }
// 
// resource "vault_approle_auth_backend_role_secret_id" "terraform" {
//   backend   = vault_auth_backend.approle.path
//   role_name = vault_approle_auth_backend_role.terraform.role_name
// }
// 
// resource "vault_approle_auth_backend_login" "terraform-login" {
//   backend   = vault_auth_backend.approle.path
//   role_id   = vault_approle_auth_backend_role.terraform.role_id
//   secret_id = vault_approle_auth_backend_role_secret_id.terraform.secret_id
// }
