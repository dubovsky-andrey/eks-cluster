# ./envs/stage/karpenter.tf

# Создаем неймспейс для Karpenter
resource "kubernetes_namespace" "karpenter" {
  depends_on = [module.eks]

  metadata {
    name = var.karpenter_namespace
  }
}

# Устанавливаем Karpenter с помощью Helm
resource "helm_release" "karpenter" {
  depends_on = [kubernetes_namespace.karpenter, module.karpenter]

  name       = "karpenter"
  namespace  = kubernetes_namespace.karpenter.metadata.0.name
  chart      = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  version    = var.karpenter_version
}

# Note: The Kubernetes manifests below are commented out because they cause
# "no client config" errors during terraform plan/validate. These should be
# applied separately after the EKS cluster is running using kubectl.

# --- Конфигурация для x86 (amd64) ---
# Apply these manifests after cluster is ready:
# kubectl apply -f - <<EOF
# apiVersion: karpenter.k8s.aws/v1beta1
# kind: EC2NodeClass
# metadata:
#   name: default-amd64
# spec:
#   role: ${module.eks.eks_managed_node_groups["initial"].iam_role_name}
#   subnetSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${var.cluster_name}
#   securityGroupSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${var.cluster_name}
#   amiFamily: AL2023
#   tags:
#     Name: ${var.cluster_name}/karpenter/amd64
# EOF

# --- Конфигурация для Graviton (arm64) ---
# Apply these manifests after cluster is ready:
# kubectl apply -f - <<EOF
# apiVersion: karpenter.k8s.aws/v1beta1
# kind: EC2NodeClass
# metadata:
#   name: default-arm64
# spec:
#   role: ${module.eks.eks_managed_node_groups["initial"].iam_role_name}
#   subnetSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${var.cluster_name}
#   securityGroupSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${var.cluster_name}
#   amiFamily: AL2023
#   tags:
#     Name: ${var.cluster_name}/karpenter/arm64
# EOF
