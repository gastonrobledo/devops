module "eks_auth" {
  source = "aidanmelen/eks-auth/aws"
  eks    = module.eks

  map_users = [
    {
      userarn  = "arn:aws:iam::590597515155:root"
      groups   = ["system:masters"]
      username = "root"
    }
  ]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_namespace" "httpbin" {
  metadata {
    name = "httpbin"
  }
}

resource "helm_release" "kube-prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = var.namespace
  version    = "36.2.0"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
}

module "nginx-controller" {
  source  = "terraform-iaac/nginx-controller/helm"

  additional_set = [
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
      value = "nlb"
      type  = "string"
    },
    {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
      value = "true"
      type  = "string"
    }
  ]
}

resource "kubernetes_deployment" "httpbin" {
  metadata {
    name = "httpbin"
    namespace = "httpbin"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "httpbin"
      }
    }

    template {
      metadata {
        labels = {
          app = "httpbin"
        }
      }

      spec {
        container {
          image = "kennethreitz/httpbin"
          name  = "httpbin"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "httpbin" {
  metadata {
    name = "httpbin"
    namespace = "httpbin"
  }

  spec {
    selector = {
      app = "httpbin"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_ingress_v1" "httpbin-ingress" {
  metadata {
    name = "httpbin"
    namespace = "httpbin"
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }
  
  spec {
    ingress_class_name = "nginx"
    default_backend {
      service {
        name = "httpbin"
        port {
          number = 80
        }
      }
    }
  }
}