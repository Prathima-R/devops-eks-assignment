variable "region" {
  description = "The AWS region to deploy the EKS cluster in."
  type        = string
  default     = "ap-south-2"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "prathima-devops-eks"
}
