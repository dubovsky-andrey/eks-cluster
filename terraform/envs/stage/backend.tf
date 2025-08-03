terraform {
  backend "s3" {
    bucket       = "dubovsky-andrey-terraform-stage-bucket"
    key          = "eks-cluster/eks-karpenter.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
