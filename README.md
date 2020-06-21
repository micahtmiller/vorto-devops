# Overview

[DevOps Engineering Challenge](https://gist.github.com/VortoEng/53a027df8665b2bcca160b8256393f4f)

# High-level plan

* Create GCP project
    * Create owner service account for Terraform
* Create infrastructure
    * IAM
    * Database
        * Postgres
    * Kubernetes?
* Load data manually to Postgres
* Configure local environment
    * Dockerfile for go program
    * Start cloud_sql_proxy for Postgres
* Create go program
    * Query database
    * Map objects for response