// module "vpc" {
//   source  = "terraform-google-modules/network/google"
//   version = "~> 6.0"
// 
//   project_id   = var.gcp_project
//   network_name = "dev"
//   routing_mode = "REGIONAL"
// 
//   subnets = [
//     {
//       subnet_name   = "dev-asia-northeast1"
//       subnet_ip     = "10.1.0.0/16"
//       subnet_region = "asia-northeast1"
//     },
//   ]
// 
//   secondary_ranges = {
//     "dev-asia-northeast1" = [
//       {
//         range_name    = "dev-asia-northeast1-pods"
//         ip_cidr_range = "10.2.0.0/16"
//       },
//       {
//         range_name    = "dev-asia-northeast1-services"
//         ip_cidr_range = "10.3.0.0/16"
//       },
//     ]
//   }
// }
