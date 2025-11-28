# main.tf - EKS Cluster Provisioning without Modules

# 1. AWS Provider and Region
provider "aws" {
  region = var.region
}

# 2. Variables (Declared here for simplicity, typically in variables.tf)
variable "region" {
  default = "us-east-1" # <--- IMPORTANT: Change this to your preferred AWS region
}

variable "cluster_name" {
  default = "simple-eks-cluster" # <--- IMPORTANT: Change to a unique cluster name
}

# --------------------------------------------------------
# CORE INFRASTRUCTURE: VPC, Internet Gateway, Subnets
# --------------------------------------------------------

# 3. Virtual Private Cloud (VPC)
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# 4. Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# 5. Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true 
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.cluster_name}-public-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" 
    "kubernetes.io/role/elb"                    = "1"      
  }
}

# 6. Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.cluster_name}-private-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" 
    "kubernetes.io/role/internal-elb"           = "1"    
  }
}

# --------------------------------------------------------
# EKS COMPONENTS: IAM Roles and Cluster
# --------------------------------------------------------

# 7. IAM Role for EKS Control Plane
resource "aws_iam_role" "eks_master_role" {
  name = "${var.cluster_name}-master-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_master_role.name
}

# 8. EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.28" # Kubernetes version

  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
    security_group_ids = []
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_policy,
  ]
}

# 9. IAM Role for EKS Node Group (Worker Nodes)
resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "node_policy_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_role.name
}

resource "aws_iam_role_policy_attachment" "node_policy_2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_role.name
}

# 10. EKS Managed Node Group (Worker Nodes)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
OAOAOA  node_group_name = "managed-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.private_subnet.id] 
  instance_types  = ["t3.medium"]                   
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node_policy_1,
    aws_iam_role_policy_attachment.node_policy_2,
  ]
}

# 11. Outputs (To get kubeconfig credentials)
output "kubeconfig_command" {
  description = "Command to configure kubectl access"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.region}"
}
