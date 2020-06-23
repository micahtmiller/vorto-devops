gcloud sql instances create vorto1 --database-version POSTGRES_12 --tier db-f1-micro
gsutil cp coffee.sql gs://vorto-dropbox/
gcloud sql import sql vorto1 gs://vorto-dropbox/coffee.sql --database public --user postgres