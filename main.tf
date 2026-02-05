locals {
  connection_sa = "bqcx-1070492604623-il6b@gcp-sa-dev-bigquery-condel.iam.gserviceaccount.com"
}

resource "google_storage_bucket" "bucket_for_rest_catalog" {
  name          = "ningk-rest"
  #location      = "us-central1"
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true
}

resource "google_biglake_iceberg_catalog" "rest_catalog" {
    name = google_storage_bucket.bucket_for_rest_catalog.name
    catalog_type = "CATALOG_TYPE_GCS_BUCKET"
    #catalog_type = "CATALOG_TYPE_BIGLAKE"
    credential_mode = "CREDENTIAL_MODE_VENDED_CREDENTIALS"
    #credential_mode = "CREDENTIAL_MODE_END_USER"
    #default_location = "gs://ningk-rest"
    #additional_locations = ["gs://ningk-so-test"]
    depends_on = [
      google_storage_bucket.bucket_for_rest_catalog
    ]
    lifecycle {
      ignore_changes = [
        default_location
      ]
    }
}

resource "google_storage_bucket_iam_member" "cv_sa_storage_admin" {
  bucket = google_storage_bucket.bucket_for_rest_catalog.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_biglake_iceberg_catalog.rest_catalog.biglake_service_account}"
}

resource "google_storage_bucket_iam_member" "connection_sa_storage_admin" {
  bucket = google_storage_bucket.bucket_for_rest_catalog.name
  role = "roles/storage.admin"
  member = "serviceAccount:${local.connection_sa}"
}

resource "google_biglake_iceberg_catalog_iam_member" "biglake_admin" {
  project = google_biglake_iceberg_catalog.rest_catalog.project
  name = google_biglake_iceberg_catalog.rest_catalog.name
  role = "roles/biglake.admin"
  member = "user:ningk@google.com"
  # condition {
  #   title = "test"
  #   description = "test"
  #   expression = "request.time < timestamp(\"2020-01-01T00:00:00Z\")"
  # }
}

# Only needed for requester-pay buckets. Otherwise, table update will permission denied.
resource "google_project_iam_member" "cv_sa_serviceusage_iam" {
  project = google_biglake_iceberg_catalog.rest_catalog.project
  role = "roles/editor"
  #role = "roles/serviceusage.serviceUsageConsumer"
  member = "serviceAccount:${google_biglake_iceberg_catalog.rest_catalog.biglake_service_account}"
}

resource "google_project_iam_member" "i_am_editor" {
  project = google_biglake_iceberg_catalog.rest_catalog.project
  role = "roles/editor"
  member = "user:ningk@google.com"
}
# This will not work since the namespace dataset is not externally visible.
# Only needed for testing p.c.n.t with existing CREATE TABLE DDL implementation.
# This should allow us to create a real BigQuery table in the IRC namespace's
# synthetic dataset (which is not what we want but doing so validates a lot of things).
#resource "google_bigquery_dataset_iam_member" "end_user_dataset_editor" {
#  # The dataset_id is always in the format of `catalog.namespace`.
#  # The creator is always the biglake robot account configured in the metastore service.
#  dataset_id = "${google_biglake_iceberg_catalog.rest_catalog.name}.uit"
#  role       = "roles/bigquery.dataEditor"
#  member     = "user:ningk@google.com"
#}

