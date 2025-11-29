variable "region" {
  description = "AWS region where resources will be deployed."
  type        = string
  default     = "ap-south-2"
}

variable "cluster_name" {
  description = "A unique name for the EKS Cluster."
  type        = string
  default     = "prathima-devops-eks"
}
