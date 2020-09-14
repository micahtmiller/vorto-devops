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
    "roles/storage.objectViewer"
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
  node_count = 3

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

# provider "kubernetes" {
#   load_config_file = false

#   host     = google_container_cluster.primary.endpoint

#   client_certificate     = google_container_cluster.primary.master_auth.0.client_certificate
#   client_key             = google_container_cluster.primary.master_auth.0.client_key
#   cluster_ca_certificate = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
# }

# # Makes sure kubectl is configured to the newly created cluster
# resource "null_resource" "kubectl" {
#     depends_on = [google_container_cluster.primary]
#     provisioner "local-exec" {
#         command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.region}"
#     }
# }

provider "helm" {
  kubernetes {
    host     = google_container_cluster.primary.endpoint
    token    = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
}

resource "helm_release" "goserver" {
    # depends_on = [null_resource.kubectl]
    depends_on = [google_container_cluster.primary]
    name = "go-server"
    chart = "../../helm/goserver"

    set {
        name = "sqlsidecar.sql_connection_name"
        value = var.sql_connection_name
    }
}


# I initially tried to use the gke provider module, but had issues
# OAuth Scopes are not being added as expected... I cannot pull the docker image

# locals {
#     cluster_type = "deploy-service"
# }

# module "gke" {
#   source                     = "terraform-google-modules/kubernetes-engine/google"
#   project_id                 = var.project_id
#   name                       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
#   region                     = var.region
#   network                    = var.network
#   subnetwork                 = var.subnetwork
#   ip_range_pods              = var.ip_range_pods
#   ip_range_services          = var.ip_range_services
#   create_service_account     = false
#   service_account            = module.gke_service_account.email

#   node_pools = [
#     {
#       name               = "default-node-pool"
#       machine_type       = "n1-standard-1"
#       min_count          = 1
#       max_count          = 2
#       local_ssd_count    = 0
#       disk_size_gb       = 10
#       disk_type          = "pd-standard"
#       image_type         = "COS"
#       auto_repair        = true
#       auto_upgrade       = true
#       preemptible        = false
#       initial_node_count = 1
#     },
#   ]

#   # Permissions issue, probably want to reduce the scopes later
#   node_pools_oauth_scopes = merge(
#       { all = [] },
#       { default-node-pool = ["https://www.googleapis.com/auth/devstorage.read_only"] }
#   )
# }


