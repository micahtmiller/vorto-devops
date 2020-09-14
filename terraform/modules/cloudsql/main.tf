# Create a unique instance name
# Paraphrased from https://github.com/terraform-google-modules/terraform-google-sql-db/blob/master/modules/postgresql/main.tf
locals {
  master_instance_name = "${var.name}-${random_id.suffix[0].hex}"
}

resource "random_id" "suffix" {
  count = 1

  byte_length = 4
}

resource "google_secret_manager_secret" "default" {
    secret_id = "sql_password"

    replication {
        automatic = true
    }
}

# resource "google_secret_manager_secret_version" "default" {
#   secret = google_secret_manager_secret.default.id
# }

# Leverage GCP module to create postgres instance
# Limitation - SQL instance name needs to be changed every time it is destroyed/recreated
module "sql-db" {
  source  = "GoogleCloudPlatform/sql-db/google//modules/postgresql"
  version = "3.1.0"

  name                 = local.master_instance_name
#   random_instance_name = true
  database_version     = var.database_version
  project_id           = var.project
  region               = var.region
  zone                 = "c"
  tier                 = var.tier

  db_name = "public"
  user_name = "postgres"
  user_name = "postgres"
#   user_password = google_secret_manager_secret_version.default.secret_data
}

# Add permissions for Cloud SQL Service Account to pull import file
resource "google_project_iam_member" "cloudsql_roles" {
  depends_on = [module.sql-db]
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${module.sql-db.instance_service_account_email_address}"
}

# Load SQL dump file
# This needs to wait a bit to let roles propagate
resource "null_resource" "load_data" {
  depends_on = [google_project_iam_member.cloudsql_roles]
  provisioner "local-exec" {
      command = "gcloud sql import sql ${module.sql-db.instance_name} gs://vorto-dropbox/coffee.sql --database public --user postgres"
  }
}