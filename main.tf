locals {
  irc_catalog_name = "ningk-dev-rest"
  irc_namespace_name = "uit"
  who_am_i = "user:ningk@google.com"
}

resource "google_storage_bucket" "bucket_for_rest_catalog" {
  name          = "${local.irc_catalog_name}"
  #location      = "us-central1"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_biglake_iceberg_catalog" "rest_catalog" {
    name = google_storage_bucket.bucket_for_rest_catalog.name
    catalog_type = "CATALOG_TYPE_GCS_BUCKET"
    credential_mode = "CREDENTIAL_MODE_VENDED_CREDENTIALS"
    #flexible catalog props
    #catalog_type = "CATALOG_TYPE_BIGLAKE"
    #credential_mode = "CREDENTIAL_MODE_END_USER"
    #default_location = "gs://ningk-rest"
    #additional_locations = ["gs://ningk-so-test"]
    depends_on = [
      google_storage_bucket.bucket_for_rest_catalog
    ]
    #lifecycle {
    #  ignore_changes = [
    #    default_location
    #  ]
    #}
}

resource "google_biglake_iceberg_namespace" "rest_namespace" {
  catalog = google_biglake_iceberg_catalog.rest_catalog.name
  namespace_id = "${local.irc_namespace_name}"
  depends_on = [
    google_biglake_iceberg_catalog.rest_catalog
  ]
}

resource "google_storage_bucket_iam_member" "cv_sa_storage_admin" {
  bucket = google_storage_bucket.bucket_for_rest_catalog.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_biglake_iceberg_catalog.rest_catalog.biglake_service_account}"
}

resource "google_biglake_iceberg_catalog_iam_member" "biglake_admin" {
  project = google_biglake_iceberg_catalog.rest_catalog.project
  name = google_biglake_iceberg_catalog.rest_catalog.name
  role = "roles/biglake.admin"
  member = "${local.who_am_i}"
  # condition {
  #   title = "test"
  #   description = "test"
  #   expression = "request.time < timestamp(\"2020-01-01T00:00:00Z\")"
  # }
}

# This shouldn't be needed once all BigLake permission checks are fixed.
resource "google_project_iam_member" "i_am_editor" {
  project = google_biglake_iceberg_catalog.rest_catalog.project
  role = "roles/bigquery.dataEditor"
  member = "${local.who_am_i}"
}

# Only needed for requester-pay buckets. Otherwise, table update will permission denied.
#resource "google_project_iam_member" "cv_sa_serviceusage_iam" {
#  project = google_biglake_iceberg_catalog.rest_catalog.project
#  role = "roles/editor"
#  #role = "roles/serviceusage.serviceUsageConsumer"
#  member = "serviceAccount:${google_biglake_iceberg_catalog.rest_catalog.biglake_service_account}"
#}

