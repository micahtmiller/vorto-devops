# Create cluster manually
gcloud container clusters create helloworld-gke \
   --num-nodes 1 \
   --enable-basic-auth \
   --issue-client-certificate \
   --zone us-central1

# Generate secret for connecting to postgres
echo "dbname=public host=localhost user=postgres password=postgres port=5432 sslmode=disable" | base64

# Deploy secret, deployment, and service manually
kubectl apply -f secret.yml #DB URI
kubectl create secret generic cloudsql-sa-secret --from-file=service_account.json=./json.secret #SA.json
kubectl apply -f deployment.yml
kubectl apply -f service.yml
