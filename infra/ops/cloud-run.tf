# This is used for the first deployment as a default value, which means this resource is
# ignored by the Terraform's state file after applying.
# Regarding continuous delivery, it will be realized by Waypoint.
# resource "google_cloud_run_v2_service" "vault-server" {
#   name     = "vault-server"
#   location = var.gcp_region
#   ingress  = "INGRESS_TRAFFIC_ALL"
# 
#   template {
#     scaling {
#       max_instance_count = 1
#       min_instance_count = 1
#     }
# 
#     timeout         = "300s"
#     service_account = google_service_account.vault-server.email
# 
#     containers {
#       image = "gcr.io/cloudrun/hello"
# 
#       resources {
#         limits = {
#           cpu    = "1000m"
#           memory = "2Gi"
#         }
#         cpu_idle = false
#       }
# 
#       ports {
#         container_port = 8200
#       }
# 
#       env {
#         name  = "GOOGLE_PROJECT"
#         value = var.gcp_project
#       }
# 
#       env {
#         name  = "GOOGLE_STORAGE_BUCKET"
#         value = google_storage_bucket.vault-data.name
#       }
# 
#       env {
#         name  = "SKIP_SETCAP"
#         value = 1
#       }
# 
#       volume_mounts {
#         mount_path = "/etc/vault/config.hcl"
#         name       = google_secret_manager_secret.vault-server-config.secret_id
#       }
#     }
# 
#     volumes {
#       name = google_secret_manager_secret.vault-server-config.secret_id
# 
#       secret {
#         secret = google_secret_manager_secret.vault-server-config.secret_id
#       }
#     }
#   }
# 
#   traffic {
#     type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
#     percent = 100
#   }
# 
#   lifecycle {
#     ignore_changes = [
#       traffic,
#       template,
#     ]
#   }
# }
# 
# ## NOTE: You should not make vault-server public before initilizing it.
# resource "google_cloud_run_service_iam_binding" "noauth" {
#   location = google_cloud_run_v2_service.vault-server.location
#   service  = google_cloud_run_v2_service.vault-server.name
#   role     = "roles/run.invoker"
#   members = [
#     "allUsers"
#   ]
# }
