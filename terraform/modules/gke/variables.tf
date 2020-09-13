# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The name of the GCP Project where all resources will be launched."
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
}

# variable "db_url" {
#   description = "Database connection URL to connect to postgres"
#   type        = string
# }

variable "k8_sa_name" {
  description = "The name of the custom service account. This parameter is limited to a maximum of 28 characters."
  type        = string
}

variable "k8_sa_description" {}

variable "cluster_name" {
  description = "The name of the gke cluster"
  type        = string
}

variable "proxy_sa_name" {}

variable "proxy_sa_description" {}

variable "sql_connection_name" {}