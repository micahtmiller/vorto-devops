resource "kubernetes_deployment" "server" {
  metadata {
    name = "go-server"
    labels = {
      App = "GoServer"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        App = "GoServer"
      }
    }

    template {
      metadata {
        labels = {
          App = "GoServer"
        }
      }

      spec {
        container {
          image = "gcr.io/sandbox-mtm/go_server:latest"
          name  = "go_server"

          port {
              container_port = 8080
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

        #   liveness_probe {
        #     http_get {
        #       path = "/"
        #       port = 8080

        #       http_header {
        #         name  = "X-Custom-Header"
        #         value = "Awesome"
        #       }
        #     }

        #     initial_delay_seconds = 3
        #     period_seconds        = 3
        #   }
        }
      }
    }
  }
}