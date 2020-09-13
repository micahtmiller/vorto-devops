terraform {
  backend "gcs" {
    bucket = "sandbox-mtm-terraform-state"
    prefix = "go_server/env/dev"
  }
}