# main.tf - Simplified EKS Cluster Provisioning without Modules

# 1. AWS Provider Configuration
provider "aws" {
  region = var.region
}

# --------------------------------------------------------
# CORE INFRASTRUCTURE: VPC, Subnets, Internet Gateway
# --------------------------------------------------------

# 2. Virtual Private Cloud (VPC)
resource "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.cluster_name}-vpc"
    # Required EKS tag for automatic discovery
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

# 4. Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true # Instances get a public IP
  availability_zone       = "${var.region}a"
  tags = {
    Name = "${var.cluster_name}-public-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned" # Required EKS tag
    "kubernetes.io/role/elb"                    = "1"      # Required for Load Balancers
  }
}

# 5. Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = "${var.region}b"
  tags = {
    Name = "${var.cluster_name}-private-subnet"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb"           = "1" # Required for Internal Load Balancers
  }
}

# --------------------------------------------------------
# EKS COMPONENTS: IAM Roles, Cluster, and Node Group
# --------------------------------------------------------

# 6. IAM Role for EKS Control Plane
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

# 7. EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_master_role.arn
  version  = "1.28" # Kubernetes version

  vpc_config {
    subnet_ids         = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]
    security_group_ids = []
  }
}

# 8. IAM Role for EKS Node Group (Worker Nodes)
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

# 9. EKS Managed Node Group (Worker Nodes)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "managed-nodes"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = [aws_subnet.private_subnet.id] # Use private subnets for worker nodes
  instance_types  = ["t3.medium"]                   # <--- Change this if needed
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
