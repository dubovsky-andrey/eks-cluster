module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name        = var.cluster_name
  vpc_id      = var.vpc_id
  subnet_ids  = var.subnets
  enable_irsa = var.enable_irsa

  tags = var.tags
}
