data "aws_availability_zones" "available" {
  state = "available"
}

data "terraform_remote_state" "eks" {
    backend = "locale"
    config = {
        path = "./terraform.tfstate"
    }
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

data "kubernetes_service" "kibana" {
  depends_on = [helm_release.kibana]
  metadata {
    name = "kibana"
  }
}

data "kubernetes_service" "elastic" {
  depends_on = [helm_release.elastic]
  metadata {
    name = "elastic"
  }
}