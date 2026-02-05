output "biglake_sa" {
  description = "BigLake credential vending service account"
  value = google_biglake_iceberg_catalog.rest_catalog.biglake_service_account
}
