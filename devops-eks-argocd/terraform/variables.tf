# variables.tf

variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "us-east-1" # <--- IMPORTANT: Change this to your preferred AWS region (e.g., ap-south-1)
}

variable "cluster_name" {
  description = "A unique name for the EKS Cluster."
  type        = string
  default     = "simple-eks-cluster-dev" # <--- IMPORTANT: Change to a unique cluster name
}
