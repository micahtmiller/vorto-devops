resource "google_sql_database_instance" "master" {
  name             = var.name
  project          = var.project
  database_version = var.database_version
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = var.tier
  }
}

resource "google_sql_database" "database" {
  project  = var.project
  name     = "public"
  instance = google_sql_database_instance.master.name
}

resource "google_project_iam_member" "cloudsql_roles" {
  project = var.project
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_sql_database_instance.master.service_account_email_address}"
}

resource "google_sql_user" "user" {
  depends_on = [
      google_sql_database_instance.master,
      google_project_iam_member.cloudsql_roles,
      google_sql_database.database
      ]
  project = var.project
  instance = google_sql_database_instance.master.name
  name     = var.sql_user
  password = var.sql_pwd

  provisioner "local-exec" {
      command = "gcloud sql import sql ${google_sql_database_instance.master.name} gs://vorto-dropbox/coffee.sql --database public --user ${google_sql_user.user.name}"
  }
}