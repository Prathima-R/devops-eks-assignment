# EKS Cluster Deployment with ArgoCD (GitOps)

This repository contains the infrastructure and application configuration to deploy an EKS (Elastic Kubernetes Service) cluster on AWS and manage an NGINX application using **ArgoCD** following the **GitOps pattern** 

[Image of GitOps workflow]

##  Project Goal

The objective is to provision all necessary infrastructure (VPC, EKS Cluster, Node Group) using **Terraform** and then automate the application deployment (NGINX) using **ArgoCD**. This deployment is **cost-optimized** and avoids the use of AWS NAT Gateways.

##  Prerequisites

You must have the following tools installed and configured on your machine:

1.  **Git:** To clone the repository.
2.  **Terraform (v1.x):** For infrastructure provisioning.
3.  **AWS CLI:** For configuring `kubectl` access and running AWS commands.
    * **Configuration:** Ensure you have run `aws configure` and set up credentials for the target AWS account, using the `ap-south-2` (Hyderabad) region.
4.  **kubectl:** For interacting with the Kubernetes cluster.

##  Deployment Instructions (Step-by-Step)

Follow these instructions sequentially to deploy the EKS cluster and the application.

### 1. Clone the Repository

Clone this repository and navigate to the Terraform directory.

```bash
# Clone the repository
git clone https://github.com/Prathima-R/devops-eks-assignment.git

# Move into the Terraform directory
cd devops-eks-assignment/terraform

2. Provision Infrastructure (Terraform)
This step deploys the VPC, EKS Control Plane, and the Managed Node Group (worker nodes in the Public Subnet for cost-saving).

# Initialize Terraform
terraform init

# Apply the configuration 
terraform apply --auto-approve
3. Set Up Kubernetes Access 
After Terraform reports Destroy complete!, configure your local kubectl to communicate with the new EKS cluster.
Bash
aws eks update-kubeconfig --name prathima-devops-eks --region ap-south-2

# Verify the worker nodes are ready 
kubectl get nodes

4. Deploy ArgoCD 
Install ArgoCD and deploy the nginx-app Application manifest.
Bash
# Install ArgoCD into the 'argocd' namespace
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Go back to the repository root directory
cd .. 

# Deploy the ArgoCD Application resource

kubectl apply -f argocd/nginx-app.yaml -n argocd

5. Access and Verification 
Access the NGINX application running in the cluster.

# Start local port-forwarding to the NGINX Service
kubectl port-forward service/nginx-service 8080:80Open your web browser and navigate to http://localhost:8080. You should see the NGINX welcome page.
To prevent further billing charges, you MUST destroy the infrastructure when finished.

1.	Stop Port Forwarding (Press Ctrl+C in the terminal running kubectl port-forward).
2.	Navigate back to the Terraform directory and run the destroy command.

Bash
cd terraform   terraform destroy --auto-approve

