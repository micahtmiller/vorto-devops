# Taking a note from Terraform and GitHub Examples
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/deploy_service/main.tf
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
# https://github.com/gruntwork-io/terraform-google-gke/blob/master/main.tf

terraform {
    required_version = ">= 0.12.24"
}

provider "google" {
    version = "~> 3.16.0"
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

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  project_id                 = var.project_id
  name                       = "${local.cluster_type}-cluster${var.cluster_name_suffix}"
  region                     = var.region
  network                    = var.network
  subnetwork                 = var.subnetwork
  ip_range_pods              = var.ip_range_pods
  ip_range_services          = var.ip_range_services
  create_service_account     = false
  service_account            = module.gke_service_account.email

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "n1-standard-1"
      min_count          = 1
      max_count          = 2
      local_ssd_count    = 0
      disk_size_gb       = 10
      disk_type          = "pd-standard"
      image_type         = "COS"
      auto_repair        = true
      auto_upgrade       = true
      preemptible        = false
      initial_node_count = 1
    },
  ]
}

module "gke_service_account" {
    source = "./modules/gke-service-account"
    project = var.project_id
    name = var.compute_engine_service_account
    description = "Service account for K8s VMs"
}

resource "helm_release" "local" {
    name = "go-server"
    chart = "./helm/goserver"
}

module "cloud_sql" {
    source = "./modules/cloudsql"
    name = "vorto"
    database_version = "POSTGRES_12"
    region = var.region
    tier = "db-f1-micro"
    sql_user = var.sql_user
    sql_pwd = var.sql_pwd
}

resource "google_sql_database_instance" "vortosql" {
  name             = "vorto"
  database_version = "POSTGRES_12"
  region           = "us-central1"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}