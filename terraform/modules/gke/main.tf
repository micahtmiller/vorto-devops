# ---- SERVICE ACCOUNTS ----

# Create K8s cluster Service Account
resource "google_service_account" "service_account" {
  project      = var.project
  account_id   = var.k8_sa_name
  display_name = var.k8_sa_description
}

# Add proper permissions
locals {
  all_service_account_roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/storage.objectViewer",
    "roles/cloudsql.client"
  ]
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = toset(local.all_service_account_roles)

  project = var.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.service_account.email}"
}

# Create Service Account to be used to connect through cloudsql_proxy
resource "google_service_account" "sql_proxy_service_account" {
  project      = var.project
  account_id   = var.proxy_sa_name
  display_name = var.proxy_sa_description
}

resource "google_project_iam_member" "sql_proxy_service_account_roles" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.sql_proxy_service_account.email}"
}

# Create json key and save to K8s secret
resource "google_service_account_key" "sql_proxy_key" {
  service_account_id = google_service_account.sql_proxy_service_account.name
}

resource "kubernetes_secret" "cloud_sa_secret" {
  metadata {
    name = "cloudsql-sa-secret"
  }
  data = {
    "service_account.json" = base64decode(google_service_account_key.sql_proxy_key.private_key)
  }
}

# resource "google_cloud_secret_manager_secret_version" "default" {
#     provider = google-beta
#     secret = "sql_password"
#     version = "1"
# }
# resource "google_secret_manager_secret_version" "default" {
#   secret = var.google_secret_id
# }

resource "kubernetes_secret" "goserver_secret" {
    metadata {
        name = "goserver-secret"
    }

    data = {
        "uri" = "dbname=public host=localhost user=postgres password=postgres port=5432 sslmode=disable"
        # "uri" = var.db_url
    }
}

# ---- KUBERNETES ----

# Create K8s Cluster
resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  project            = var.project
  location           = var.region
  remove_default_node_pool = true
  initial_node_count       = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  cluster_autoscaling {
    enabled = false
    auto_provisioning_defaults {
        service_account = google_service_account.service_account.email
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "service-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "e2-standard-2"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # oauth_scopes = [
    #   "https://www.googleapis.com/auth/cloud-platform"
    #   "https://www.googleapis.com/auth/logging.write",
    #   "https://www.googleapis.com/auth/monitoring",
    #   "https://www.googleapis.com/auth/devstorage.read_only",
      
    # ]
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  load_config_file       = false
  host                   = google_container_cluster.primary.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    load_config_file       = false
    host     = google_container_cluster.primary.endpoint
    token    = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

resource "helm_release" "goserver" {
    depends_on = [google_container_cluster.primary]
    name = "go-server"
    chart = "../../helm/goserver"

    set {
        name = "sqlsidecar.sql_connection_name"
        value = var.sql_connection_name
    }
}


