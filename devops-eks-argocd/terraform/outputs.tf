# outputs.tf - Outputs for EKS cluster access and information

output "kubeconfig_command" {
  description = "Command to configure kubectl access"
  value       = "aws eks update-kubeconfig --name ${aws_eks_cluster.main.name} --region ${var.region}"
}

output "cluster_endpoint" {
  description = "The endpoint URL for the EKS control plane."
  value       = aws_eks_cluster.main.endpoint
}

output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.eks_vpc.id
}
