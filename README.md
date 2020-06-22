# Overview

[DevOps Engineering Challenge](https://gist.github.com/VortoEng/53a027df8665b2bcca160b8256393f4f)

# Learn development/deployment framework

* Initialize
    * Create GCP project (done)
    * Configure VS Code for Go (done)
    * Configure cloud_sql_proxy locally for Postgres

* Go Server
    * Develop hello world (done)
    * Implement Cloud Build pipeline (done)
    * Build/push image (done)
* K8s
    * Manual
        * Create cluster (done)
        * Create deployment (done)
        * Create service (done)
    * Helm
        * Create helm chart (done)
        * Configure deployment (done)
        * Configure service (done)
        * Configure ingress
    * Terraform
        * Create cluster
        * Deploy helm chart

# Create solution

* Create infrastructure
    * Terraform
        * K8s
        * Helm
            * cloud_sql_proxy
            * go_server
        * Database
            * Postgres
* Load data manually to Postgres
* Create go program
    * Getting started with go (done)
    * Query database
    * Map objects for response