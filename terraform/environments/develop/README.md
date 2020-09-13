# Overview

Terraform is great, except when it's not.  So, I started out trying to use providers, and modules available through the community.  Sometimes this worked, and other times it did not, so I actually spent a lot of time debugging the layers of abstraction added in when using these products.  Eventually, I got everything working and tried to get it to a simple implementation.  Simple is always best, right?

## Deployment Overview

Everything is deployed/managed by Terraform.  You should be able to re-deploy fairly easily, given you have the correct permissions on the GCP project and APIs enabled (Kubernetes and Cloud SQL).

Create a `terraform.tfvars` file, then run: 

```sh
terraform init
terraform apply
```

## Sequence Diagram

```mermaid
sequenceDiagram
    participant tf as TerraForm
    participant k8sa as K8s Service Account
    participant sqlsa as SQL Service Account
    participant sqlkey as SQL Service Account Key
    participant sql as Cloud SQL
    participant sqldump as SQL Dump File
    participant k8 as Kubernetes
    participant k8sqlsecret as Kubernetes Secret - SQL Service Account Key
    participant k8gosecret as Kubernetes Secret - Go connection string
    participant helm as Helm

    tf ->> sqlsa: Create SQL Service Account
    tf ->> k8sa: Create K8s Service Account
    tf ->> sql: Create Cloud SQL instance
    tf ->> sqldump: Load SQL Dump file
    tf ->> k8: Create K8s cluster
    tf ->> k8sqlsecret: Create secret from file
    tf ->> k8gosecret: Create secret from Terraform variable
    tf ->> helm: Deploy Helm Chart
```