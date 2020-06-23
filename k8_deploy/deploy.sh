gcloud container clusters create helloworld-gke \
   --num-nodes 1 \
   --enable-basic-auth \
   --issue-client-certificate \
   --zone us-central1

kubectl apply -f deployment.yml
kubectl apply -f service.yml