provider "google" {
  user_project_override = true
  billing_project = "ningk-stackoverflow"
  biglake_iceberg_custom_endpoint = "https://ningk.c.googlers.com:8790/"
  iam_custom_endpoint = "https://staging-iam-googleapis.sandbox.google.com/"
}
