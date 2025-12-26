provider "aws" {
  region = "eu-north-1"
}

resource "aws_eks_cluster" "eks" {
  name     = "demo-eks"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
}
