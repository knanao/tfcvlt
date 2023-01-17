variable "encoded_auth" {
  type = string
  env = ["ENCODED_AUTH"]
}

project = "vault-server"

app "vault-server" {
  build {
    use "docker-pull" {
      image = "asia.gcr.io/knanao/vault"
      tag   = "v1.12.2"
    }
  }

  deploy {
    use "google-cloud-run" {
      project  = "knanao"
      location = "asia-northeast1"

      port = 8200

      static_environment = {
        "GOOGLE_PROJECT": "knanao",
        "GOOGLE_STORAGE_BUCKET": "knanao-vault-data",
        "SKIP_SETCAP": "1",
      }

      capacity {
        memory                     = 2048 
        cpu_count                  = 1
        max_requests_per_container = 50
        request_timeout            = 300
      }

      service_account_name = "vault-server@knanao.iam.gserviceaccount.com"

      auto_scaling {
        max = 1
      }

      unauthenticated = true
    }
  }

  release {
    use "google-cloud-run" {}
  }
}
