// resource "google_container_cluster" "dev" {
//   name     = "dev"
//   location = var.gcp_region
// 
//   network    = module.vpc.network_name
//   subnetwork = module.vpc.subnets_names[0]
// 
//   ip_allocation_policy {
//     cluster_secondary_range_name  = "${module.vpc.subnets_names[0]}-pods"
//     services_secondary_range_name = "${module.vpc.subnets_names[0]}-services"
//   }
// 
//   # Enable Autopilot for this cluster
//   enable_autopilot = true
// 
//   vertical_pod_autoscaling {
//     enabled = true
//   }
// 
//   depends_on = [
//     module.vpc
//   ]
// }
