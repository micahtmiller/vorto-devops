# Create SQL instance
gcloud sql instances create vorto1 --database-version POSTGRES_12 --tier db-f1-micro

# Move sql dump file to GCS
gsutil cp coffee.sql gs://vorto-dropbox/

# Import sql dump file
gcloud sql import sql vorto1 gs://vorto-dropbox/coffee.sql --database public --user postgres