# Create new cluster manually

```
gcloud container clusters create helloworld-gke \
   --num-nodes 1 \
   --enable-basic-auth \
   --issue-client-certificate \
   --zone us-central1
```

# Get Cluster info

```sh
gcloud container clusters describe vorto-server-cluster --zone us-central1
```

https://cloud.google.com/kubernetes-engine/docs/tutorials/hello-app
```sh
kubectl create deployment hello-app --image=gcr.io/${PROJECT_ID}/hello-app:v1 --cluster vorto-server-cluster
OR
kubectl apply -f nginx-deployment.yaml
```

```
docker run -d --rm --name test -p 8080:8080 gcr.io/sandbox-mtm/go_server:latest
```

# Configure kubectl for deployed K8 instance

```
gcloud container clusters get-credentials deploy-service-cluster --region us-central1
```