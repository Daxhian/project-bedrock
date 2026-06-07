variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "project-bedrock-cluster"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "vpc_name" {
  description = "VPC name tag"
  type        = string
  default     = "project-bedrock-vpc"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "AZs to deploy into"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS node group"
  type        = string
  default     = "t3.medium"
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 3
}

variable "db_username" {
  description = "Master username for RDS instances"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS instances"
  type        = string
  sensitive   = true
}

variable "student_id" {
  description = "AltSchool student ID for unique resource naming"
  type        = string
  default     = "altsoe0253240"
}
