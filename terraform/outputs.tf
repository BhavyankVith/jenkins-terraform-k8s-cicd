output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.eks.name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster API server endpoint"
  value       = aws_eks_cluster.eks.endpoint
}

output "eks_cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.eks.arn
}

output "eks_cluster_certificate_authority" {
  description = "Base64 encoded certificate data required for kubectl access"
  value       = aws_eks_cluster.eks.certificate_authority[0].data
}

output "region" {
  description = "AWS region where the EKS cluster is deployed"
  value       = var.region
}