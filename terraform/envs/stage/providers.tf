provider "aws" {
  region = var.region
}

# Определяем провайдер Kubernetes ОДИН РАЗ с псевдонимом "eks"
provider "kubernetes" {
  alias                  = "eks"
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Провайдер helm остается пустым, как и договаривались.
provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}
