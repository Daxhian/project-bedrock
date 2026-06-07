terraform {
  backend "s3" {
    bucket = "project-bedrock-tfstate-491085407784"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"

    # Encryption at rest for state file
    encrypt = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project = "karatu-2025-capstone"
    }
  }
}

# Kubernetes provider — points at the EKS cluster
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Helm provider — for installing AWS Load Balancer Controller
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}
