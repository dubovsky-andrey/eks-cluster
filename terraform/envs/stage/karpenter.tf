################################
# 1. AWS-ресурсы для Karpenter (IAM, SQS, EventBridge)
################################
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  cluster_name = module.eks.cluster_name

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["initial"].iam_role_arn
  create_access_entry  = false

  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

# ################################
# # 2. Устанавливаем Karpenter через Helm
# ################################
# resource "helm_release" "karpenter" {
#   provider = kubernetes.eks # <-- Это вы сделали правильно!

#   name             = "karpenter"
#   repository       = "https://charts.karpenter.sh"
#   chart            = "karpenter"
#   version          = var.karpenter_version
#   namespace        = var.karpenter_namespace
#   create_namespace = true
#   skip_crds        = false

#   set = [
#     {
#       name  = "serviceAccount.create"
#       value = "false"
#     },
#     {
#       name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#       value = module.karpenter.iam_role_arn
#     },
#     {
#       name  = "settings.aws.clusterName"
#       value = module.eks.cluster_name
#     },
#     {
#       name  = "settings.aws.clusterEndpoint"
#       value = module.eks.cluster_endpoint
#     },
#     {
#       name  = "settings.aws.subnetSelector"
#       value = yamlencode({ "karpenter.sh/discovery" = var.cluster_name })
#     },
#     {
#       name  = "settings.aws.securityGroupSelector"
#       value = yamlencode({ "kubernetes.io/cluster/${var.cluster_name}" = "owned" })
#     }
#   ]

#   depends_on = [module.karpenter]
# }

# ################################
# # 3. Применяем Provisioner через kubernetes_manifest (ПРАВИЛЬНЫЙ СПОСОБ)
# ################################
# resource "kubernetes_manifest" "default_provisioner" {
#   provider = kubernetes.eks # <-- Указываем правильный провайдер!

#   manifest = {
#     "apiVersion" = "karpenter.sh/v1alpha5"
#     "kind"       = "Provisioner"
#     "metadata" = {
#       "name"      = "default"
#       "namespace" = var.karpenter_namespace
#     }
#     "spec" = {
#       "requirements" = [
#         {
#           "key"      = "karpenter.k8s.aws/instance-family"
#           "operator" = "In"
#           "values"   = ["t3"]
#         },
#       ]
#       "provider" = {
#         "subnetSelector" = {
#           "karpenter.sh/discovery" = var.cluster_name
#         }
#         "securityGroupSelector" = {
#           "kubernetes.io/cluster/${var.cluster_name}" = "owned"
#         }
#       }
#       "ttlSecondsAfterEmpty" = 30
#     }
#   }

#   depends_on = [helm_release.karpenter]
# }
