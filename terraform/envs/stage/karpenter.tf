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

# --- Конфигурация для x86 (amd64) ---

resource "kubernetes_manifest" "karpenter_node_class_amd64" {
  provider   = kubernetes
  depends_on = [helm_release.karpenter]

  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1beta1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = "default-amd64"
    }
    "spec" = {
      "role" = module.eks.eks_managed_node_groups["initial"].iam_role_name
      "subnetSelectorTerms" = [
        { "tags" = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      "securityGroupSelectorTerms" = [
        { "tags" = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      "amiFamily" = "AL2023"
      "tags" = {
        "Name" = "${var.cluster_name}/karpenter/amd64"
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_node_pool_amd64" {
  provider   = kubernetes
  depends_on = [kubernetes_manifest.karpenter_node_class_amd64]

  manifest = {
    "apiVersion" = "karpenter.sh/v1beta1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "default-amd64"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "nodeClassRef" = {
            "name" = kubernetes_manifest.karpenter_node_class_amd64.manifest.metadata.name
          }
          "requirements" = [
            { "key" = "kubernetes.io/arch", "operator" = "In", "values" = ["amd64"] },
            { "key" = "karpenter.sh/capacity-type", "operator" = "In", "values" = ["spot", "on-demand"] }
          ]
        }
      }
      "disruption" = {
        "consolidationPolicy" = "WhenUnderutilized"
      }
      "limits" = { "cpu" = "1000" }
    }
  }
}

# --- Конфигурация для Graviton (arm64) ---

resource "kubernetes_manifest" "karpenter_node_class_arm64" {
  provider   = kubernetes
  depends_on = [helm_release.karpenter]

  manifest = {
    "apiVersion" = "karpenter.k8s.aws/v1beta1"
    "kind"       = "EC2NodeClass"
    "metadata" = {
      "name" = "default-arm64"
    }
    "spec" = {
      "role" = module.eks.eks_managed_node_groups["initial"].iam_role_name
      "subnetSelectorTerms" = [
        { "tags" = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      "securityGroupSelectorTerms" = [
        { "tags" = { "karpenter.sh/discovery" = var.cluster_name } }
      ]
      # Для Graviton часто используется специфичный AMI Family
      "amiFamily" = "AL2023"
      "tags" = {
        "Name" = "${var.cluster_name}/karpenter/arm64"
      }
    }
  }
}

resource "kubernetes_manifest" "karpenter_node_pool_arm64" {
  provider   = kubernetes
  depends_on = [kubernetes_manifest.karpenter_node_class_arm64]

  manifest = {
    "apiVersion" = "karpenter.sh/v1beta1"
    "kind"       = "NodePool"
    "metadata" = {
      "name" = "default-arm64"
    }
    "spec" = {
      "template" = {
        "spec" = {
          "nodeClassRef" = {
            "name" = kubernetes_manifest.karpenter_node_class_arm64.manifest.metadata.name
          }
          "requirements" = [
            # Ключевое отличие - указываем arm64
            { "key" = "kubernetes.io/arch", "operator" = "In", "values" = ["arm64"] },
            { "key" = "karpenter.sh/capacity-type", "operator" = "In", "values" = ["spot", "on-demand"] }
          ]
        }
      }
      "disruption" = {
        "consolidationPolicy" = "WhenUnderutilized"
      }
      "limits" = { "cpu" = "1000" }
    }
  }
}
