resource "kubernetes_namespace" "argo_cd" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "argocd_secret" {
  metadata {
    name      = "argocd-secret"
    namespace = kubernetes_namespace.argo_cd.metadata[0].name
  }
  data = {
    admin.password = base64encode("password")
    admin.passwordMtime = base64encode(timestamp())
  }
  type = "Opaque"
}

resource "kubernetes_deployment" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argo_cd.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "argocd-server"
      }
    }

    template {
      metadata {
        labels = {
          app = "argocd-server"
        }
      }

      spec {
        container {
          name  = "argocd-server"
          image = "argoproj/argocd:v2.1.2"

          port {
            container_port = 80
          }

          volume_mount {
            name       = "argocd-secret"
            mount_path = "/etc/argocd/secret"
            read_only  = true
          }
        }

        volume {
          name = "argocd-secret"

          secret {
            secret_name = kubernetes_secret.argocd_secret.metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = kubernetes_namespace.argo_cd.metadata[0].name
  }

  spec {
    selector = {
      app = "argocd-server"
    }

    port {
      protocol = "TCP"
      port     = 80
      target_port = 80
    }
  }
}
