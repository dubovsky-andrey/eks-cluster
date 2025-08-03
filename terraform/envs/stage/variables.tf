variable "name" {
  description = "Name prefix for resources"
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 50
    error_message = "Name must be between 1 and 50 characters."
  }
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.cluster_name))
    error_message = "Cluster name must start with a letter and contain only alphanumeric characters and hyphens."
  }
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  validation {
    condition     = can(regex("^1\\.\\d+$", var.cluster_version))
    error_message = "Cluster version must be in format 1.x (e.g., 1.28, 1.33)."
  }
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  validation {
    condition     = can(regex("^[a-z]+-[a-z]+-[1-9]$", var.region))
    error_message = "Region must be a valid AWS region format (e.g., us-east-1, eu-west-1)."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  validation {
    condition     = length(var.azs) >= 1 && length(var.azs) <= 6
    error_message = "Must specify between 1 and 6 availability zones."
  }
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  validation {
    condition     = length(var.public_subnets) == length(var.azs)
    error_message = "Number of public subnets must match number of availability zones."
  }
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  validation {
    condition     = length(var.private_subnets) == length(var.azs)
    error_message = "Number of private subnets must match number of availability zones."
  }
}

variable "karpenter_namespace" {
  description = "Kubernetes namespace for Karpenter"
  type        = string
}

variable "karpenter_version" {
  description = "Karpenter version to deploy"
  type        = string
  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.karpenter_version))
    error_message = "Karpenter version must be in semantic versioning format (x.y.z)."
  }
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
}

