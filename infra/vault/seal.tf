resource "google_kms_key_ring" "vault-server" {
  name     = "vault-server"
  location = "global"
}

resource "google_kms_crypto_key" "vault-seal" {
  name     = "vault-seal"
  key_ring = google_kms_key_ring.vault-server.id
}

resource "google_kms_crypto_key_iam_member" "vault-seal" {
  crypto_key_id = google_kms_crypto_key.vault-seal.id
  role          = "roles/cloudkms.cryptoOperator"
  member        = "serviceAccount:${google_service_account.vault-server.email}"
}

resource "google_kms_crypto_key_iam_member" "vault-seal-admin" {
  crypto_key_id = google_kms_crypto_key.vault-seal.id
  role          = "roles/cloudkms.admin"
  member        = "serviceAccount:${google_service_account.vault-server.email}"
}
