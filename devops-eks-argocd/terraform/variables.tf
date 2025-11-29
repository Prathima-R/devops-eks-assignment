variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
  default     = "prathima-eks-cluster"

variable "ssh_key_name" {
  description = "Name of the EC2 Key Pair for SSH access to worker nodes."
  type        = string
  default     = "pratice"
}



