# EKS Cluster with Karpenter

This repository contains Terraform code to provision an Amazon EKS cluster with Karpenter for auto-scaling.

## Architecture

- **VPC**: Multi-AZ VPC with public and private subnets
- **EKS**: Kubernetes cluster with IRSA enabled
- **Karpenter**: Auto-scaling solution for EKS nodes
- **Networking**: NAT Gateway for private subnet internet access

## Prerequisites

- Terraform >= 1.4.0
- AWS CLI configured
- kubectl installed
- helm installed

## Quick Start

1. **Initialize Terraform**:

   ```bash
   cd terraform/envs/stage
   terraform init
   ```

2. **Review the plan**:

   ```bash
   terraform plan
   ```

3. **Apply the configuration**:

   ```bash
   terraform apply
   ```

4. **Configure kubectl**:
   ```bash
   aws eks update-kubeconfig --region us-east-1 --name demo-eks
   ```

## Configuration

### Variables

Key variables can be customized in `terraform.tfvars`:

- `region`: AWS region (default: us-east-1)
- `cluster_name`: EKS cluster name (default: demo-eks)
- `cluster_version`: Kubernetes version (default: 1.33)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)

### Backend Configuration

The state is stored in S3. Update `backend.tf` with your bucket details:

```hcl
terraform {
  backend "s3" {
    bucket = "your-tf-state-bucket"
    key    = "stage/eks-karpenter.tfstate"
    region = "us-east-1"
  }
}
```

## Security Features

- **IRSA**: IAM roles for service accounts enabled
- **Private subnets**: Worker nodes in private subnets
- **Security groups**: Restrictive security group rules
- **Audit logging**: EKS control plane audit logs enabled

## Karpenter Configuration

Karpenter is configured to:

- Use spot instances for cost optimization
- Support both AMD64 and ARM64 architectures
- Auto-scale based on pod requirements
- TTL of 300 seconds for node expiration

## Outputs

After deployment, you'll get:

- Cluster endpoint and certificate
- VPC and subnet IDs
- OIDC provider ARN
- Karpenter namespace

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

## Best Practices

1. **State Management**: Use remote state storage (S3 + DynamoDB)
2. **Tagging**: All resources are tagged for cost tracking
3. **Security**: Follow least privilege principle for IAM policies
4. **Monitoring**: Enable CloudWatch logs for EKS
5. **Backup**: Consider using Velero for cluster backup

## Troubleshooting

### Common Issues

1. **Provider Configuration**: Ensure AWS credentials are configured
2. **VPC Limits**: Check VPC limits in your AWS account
3. **IAM Permissions**: Verify sufficient IAM permissions for EKS

### Useful Commands

```bash
# Check cluster status
kubectl get nodes

# View Karpenter logs
kubectl logs -n karpenter -l app.kubernetes.io/name=karpenter

# Check EKS cluster logs
aws logs describe-log-groups --log-group-name-prefix "/aws/eks/demo-eks"
```

## Contributing

1. Follow Terraform best practices
2. Add variable validation
3. Update documentation
4. Test changes in a non-production environment

## License

This project is licensed under the MIT License.
