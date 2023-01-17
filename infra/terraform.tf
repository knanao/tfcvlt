terraform {
  cloud {
    organization = "knanao"

    workspaces {
      name = "tfcvlt"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.47.0"
    }

    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.48.0"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "3.12.0"
    }

    waypoint = {
      source  = "hashicorp-dev-advocates/waypoint"
      version = "0.3.0"
    }
  }

  required_version = ">= 1.3.0"
}
