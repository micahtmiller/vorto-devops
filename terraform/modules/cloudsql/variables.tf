variable "name" {
    description = "Cloud SQL Instance Name"
    type = "string"
}

variable "database_version" {
    description = "POSTGRES_12"
    type = "string"
}

variable "region" {
    description = "GCP region"
    type = "string"
}

variable "tier" {
    description = "DB tier"
    type = "string"
}