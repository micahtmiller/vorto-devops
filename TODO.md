# ToDo

* Bonus items
    * Use gRPC
    * Create probability endpoint
* Current tech debt
    * Terraform
        * Loading SQL dump file usually fails the first time you run `terraform apply` due to the service account roles not propagating... re-running apply a second time works as expected
        * 
    * Go 
        * Tests!
        * Create multi-staged Dockerfile
        * Add gRPC endpoint/s
        * Code could be MUCH better and use something like https://github.com/sharfanis/VORTO-GO ??
    * Cloud Build pipeline
        * Run tests
* Reliability Monitoring
    * Create alerting policy in stackdriver
    * Create reliability metrics (needs to be discussed)
* Security
    * Create proper ingress to better control inbound traffic
    * Make sure all secrets are properly hidden in code