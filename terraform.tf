terraform {
  cloud {
    organization = "knanao"

    workspaces {
      name = "tfcvltdemo"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.47.0"
    }
  }

  required_version = ">= 1.3.0"
}
