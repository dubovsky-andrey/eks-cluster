module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnets

  # === Настройки доступа к API-server ===
  endpoint_public_access       = true
  endpoint_private_access      = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] # здесь можно указать ваш IP в формате "A.B.C.D/32"



  addons = {
    # CNI и сетевые аддоны
    "vpc-cni"    = { before_compute = true, most_recent = true }
    "coredns"    = { before_compute = true, most_recent = true }
    "kube-proxy" = { before_compute = true, most_recent = true }
  }

  # make sure you (or the caller) are mapped to system:masters
  enable_cluster_creator_admin_permissions = true



  eks_managed_node_groups = {
    initial = {
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      ami_type       = "BOTTLEROCKET_x86_64"
    }
  }

  tags = var.tags
}
