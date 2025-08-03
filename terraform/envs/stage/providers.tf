provider "aws" {
  region = var.region
}

# Провайдер для работы с ресурсами Kubernetes (например, неймспейсы)
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {}
