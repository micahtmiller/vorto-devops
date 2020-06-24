resource "google_sql_database_instance" "master" {
  name             = var.name
  database_version = var.database_version
  region           = var.region

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = var.tier
  }
}

resource "google_sql_user" "user" {
  depends_on = [
    "google_sql_database_instance.master",
    "google_sql_database_instance.replica",
  ]

  instance = "${google_sql_database_instance.master.name}"
  name     = "${var.sql_user}"
  password = "${var.sql_pass}"
}