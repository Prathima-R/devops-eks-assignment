# variables.tf

variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "ap-south-2" # <--- IMPORTANT: Change this to your preferred AWS region (e.g., ap-south-1)
}

variable "cluster_name" {
  description = "A unique name for the EKS Cluster."
  type        = string
  default     = "prathima-devops-eks" # <--- IMPORTANT: Change to a unique cluster name
}
