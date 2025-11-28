# variables.tf

variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "ap-south-2" # <-- Set to AP-SOUTH-2 (Hyderabad)
}

variable "cluster_name" {
  description = "A unique name for the EKS Cluster."
  type        = string
  default     = "prathima-devops-eks" # <-- Set to your requested cluster name
}
