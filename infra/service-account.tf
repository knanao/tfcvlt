resource "google_service_account" "vault-server" {
  account_id   = "vault-server"
  display_name = "vault-server"
}

resource "google_project_iam_member" "vault-server" {
  for_each = toset([
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountKeyAdmin",
    "roles/resourcemanager.projectIamAdmin",
  ])

  project = var.gcp_project
  member  = "serviceAccount:${google_service_account.vault-server.email}"
  role    = each.key
}

# resource "google_service_account" "waypoint-runner" {
#   account_id   = "waypoint-runner"
#   display_name = "waypoint-runner"
# }
# 
# resource "google_project_iam_member" "waypoint-runner" {
#   for_each = toset([
#     "roles/storage.objectAdmin"
#   ])
# 
#   project = var.gcp_project
#   member  = "serviceAccount:${google_service_account.waypoint-runner.email}"
#   role    = each.key
# }
