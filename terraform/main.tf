# provider "aws" {
#   region = "eu-north-1"
# }

# resource "aws_eks_cluster" "eks" {
#   name     = "demo-eks"
#   role_arn = aws_iam_role.eks_role.arn

#   vpc_config {
#     subnet_ids = var.subnet_ids
#   }
# }

// New approach

provider "aws" {
  region = var.region
}

# 1. Define the IAM Role for the EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

  # This policy allows the EKS service to assume this role
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# 2. Attach the mandatory AmazonEKSClusterPolicy to the role
resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# 3. Define the EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name 
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Crucial: Ensure the IAM role and policy are fully created before the cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment
  ]
}
