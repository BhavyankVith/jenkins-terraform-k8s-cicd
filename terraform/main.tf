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

# provider "aws" {
#   region = var.region
# }

# # 1. Define the IAM Role for the EKS Cluster
# resource "aws_iam_role" "eks_role" {
#   name = "eks-cluster-role"

#   # This policy allows the EKS service to assume this role
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# # 2. Attach the mandatory AmazonEKSClusterPolicy to the role
# resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_role.name
# }

# # 3. Define the EKS Cluster
# resource "aws_eks_cluster" "eks" {
#   name     = var.cluster_name 
#   role_arn = aws_iam_role.eks_role.arn

#   vpc_config {
#     subnet_ids = var.subnet_ids
#   }

#   # Crucial: Ensure the IAM role and policy are fully created before the cluster
#   depends_on = [
#     aws_iam_role_policy_attachment.eks_policy_attachment
#   ]
# }


// Updated code for hosting app now

provider "aws" {
  region = var.region
}

# 1. Define the IAM Role for the EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "eks-cluster-role"

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

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_role.name
}

# 2. Define the EKS Cluster
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name 
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids

    # Enable both for easier troubleshooting
    endpoint_public_access  = true  # Allows you to use kubectl from your laptop
    endpoint_private_access = true # Allows worker nodes to talk to the API inside the VPC
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy_attachment
  ]
}

# --- NEW CODE BELOW: WORKER NODES ---

# 3. Define IAM Role for Worker Nodes
resource "aws_iam_role" "node_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
    Version = "2012-10-17"
  })
}

# 4. Attach mandatory policies for Worker Nodes
resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_role.name
}

# 5. Define the Managed Node Group
resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "flask-app-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 2 # Starts 2 servers to run your pods
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.micro"] # Standard size for testing

  # Ensure permissions are created before nodes try to join the cluster
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}