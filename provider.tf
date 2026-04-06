provider "google" {
  project = "ningk-stackoverflow"
  region  = "us-central1"
  zone    = "us-central1-a"

  user_project_override = true
  billing_project = "ningk-stackoverflow"

  #Test environment
  # biglake_iceberg_custom_endpoint = "https://test-biglake.sandbox.googleapis.com/"

  # Dev stack
  # need SSL_CERT_FILE="/tmp/certs/local/ca.pem"
  biglake_iceberg_custom_endpoint = "https://ningk.c.googlers.com:8790/"

  # Dev stack and test environment common
  # - staging IAM
  iam_custom_endpoint = "https://staging-iam-googleapis.sandbox.google.com/"
}
