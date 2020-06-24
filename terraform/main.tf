# Taking a note from Terraform and GitHub Examples
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/deploy_service/main.tf
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
# https://github.com/gruntwork-io/terraform-google-gke/blob/master/main.tf

terraform {
    required_version = ">= 0.12.24"
}

provider "google" {
    version = "~> 3.16.0"
    project = var.project_id
    region  = var.region
}

provider "kubernetes" {
  load_config_file       = false
  host                   = module.gke.endpoint
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

data "google_client_config" "default" {}

locals {
    cluster_type = "deploy-service"
}

resource "google_container_cluster" "primary" {
  name               = "vorto-service-cluster"
  project            = var.project_id
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
        service_account = module.gke_service_account.email
    }
  }
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "service-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = false
    machine_type = "n1-standard-1"

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

# OAuth Scopes are not being added as expected... I cannot pull the docker image
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

resource "null_resource" "kubectl" {
    depends_on = [google_container_cluster.primary]
    provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${google_container_cluster.primary.region}"
  }
}

module "gke_service_account" {
    source = "./modules/gke-service-account"
    project = var.project_id
    name = var.compute_engine_service_account
    description = "Service account for K8s VMs"
}

module "cloud_sql" {
    source = "./modules/cloudsql"
    project = var.project_id
    name = "vorto3"
    database_version = "POSTGRES_12"
    region = var.region
    tier = "db-f1-micro"
    sql_user = var.sql_user
    sql_pwd = var.sql_pwd
}

# resource "helm_release" "goserver" {
#     depends_on = [null_resource.kubectl]
#     name = "go-server"
#     chart = "./helm/goserver"
# }

# resource "helm_release" "cloudsql-sidecar" {
#   name       = "cloudsql"
#   repository = "https://charts.rimusz.net" 
#   chart      = "gcloud-sqlproxy"


#   set {
#     name  = "serviceAccountKey"
#     value = filebase64("./json.secret")
#   }

#   set {
#     name  = "cloudsql.instances[0].instance"
#     value = module.cloud_sql.sql_connection_name
#   }

#   set {
#     name  = "cloudsql.instances[0].region"
#     value = var.region
#   }

#   set {
#     name  = "cloudsql.instances[0].port"
#     value = 5432
#   }
  
# }