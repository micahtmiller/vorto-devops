# Taking a note from Terraform and GitHub Examples
# https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/blob/master/examples/deploy_service/main.tf
# https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
# https://github.com/gruntwork-io/terraform-google-gke/blob/master/main.tf
# https://github.com/mudrii/gke_sql_terraform/blob/master/infra/gke/main.tf

terraform {
    required_version = ">= 0.12.26"
}

provider "google" {
    version = "~> 3.24.0"
    project = var.project_id
    region  = var.region
}

provider "google-beta" {
    version = ">= 3.8"
    project = var.project_id
}

module "cloud_sql" {
    source = "../../modules/cloudsql"
    project = var.project_id
    name = "vorto"
    database_version = "POSTGRES_12"
    region = var.region
    tier = "db-f1-micro"
}

module "gke" {
    source = "../../modules/gke"
    cluster_name = "vorto-service-cluster"
    project = var.project_id
    region = var.region
    sql_connection_name = module.cloud_sql.sql_connection_name
    proxy_sa_name = "sql-proxy"
    proxy_sa_description = "Service Account for Cloud SQL Proxy"
    k8_sa_name = var.compute_engine_service_account
    k8_sa_description = "Service account for K8s VMs"
    # db_url = var.db_url
}