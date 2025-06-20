resource "kubernetes_namespace" "todo_ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_config_map" "todo_config" {
  metadata {
    name      = "todo-config"
    namespace = var.namespace
  }
  data = {
    APP_NAME = "TodoAppK8s"
  }
}

resource "kubernetes_secret" "todo_secret" {
  metadata {
    name      = "todo-secret"
    namespace = var.namespace
  }
  data = {
    PORT = base64encode("3000")
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "todo_app" {
  metadata {
    name      = "todo-deployment"
    namespace = var.namespace
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "todo"
      }
    }

    template {
      metadata {
        labels = {
          app = "todo"
        }
      }

      spec {
        container {
          name  = "todo-container"
          image = "zaifdk93/nodejs-todo:latest"

          port {
            container_port = 3000
          }

          env {
            name = "APP_NAME"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.todo_config.metadata[0].name
                key  = "APP_NAME"
              }
            }
          }

          env {
            name = "PORT"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.todo_secret.metadata[0].name
                key  = "PORT"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "todo_svc" {
  metadata {
    name      = "todo-service"
    namespace = var.namespace
  }

  spec {
    type = "NodePort"

    selector = {
      app = "todo"
    }

    port {
      port        = 3000
      target_port = 3000
      node_port   = 30036
    }
  }
}
