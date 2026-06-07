# Dependency chain:
#   IAM (cluster + node roles)
#    ↓
#   EKS (uses those roles, produces OIDC issuer)
#    ↓
#   IRSA (uses OIDC issuer to create LBC + CloudWatch roles)

# ─────────────────────────────────────────
# VPC
# ─────────────────────────────────────────
module "vpc" {
  source = "../../modules/vpc"

  vpc_name             = var.vpc_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  cluster_name         = var.cluster_name
}

# ─────────────────────────────────────────
# IAM — cluster role, node role, dev user
# No dependency on EKS
# ─────────────────────────────────────────
module "iam" {
  source = "../../modules/iam"

  cluster_name = var.cluster_name
}

# ─────────────────────────────────────────
# EKS — depends on IAM roles + VPC
# Produces: OIDC issuer
# ─────────────────────────────────────────
module "eks" {
  source = "../../modules/eks"

  cluster_name       = var.cluster_name
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
  cluster_role_arn   = module.iam.cluster_role_arn
  node_role_arn      = module.iam.node_role_arn
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
  node_min_size      = var.node_min_size
  node_max_size      = var.node_max_size

  depends_on = [module.iam]
}

# ─────────────────────────────────────────
# IRSA — depends on EKS OIDC issuer
# Creates: LBC role, CloudWatch role
# ─────────────────────────────────────────
module "irsa" {
  source = "../../modules/irsa"

  cluster_name   = var.cluster_name
  aws_account_id = data.aws_caller_identity.current.account_id
  oidc_issuer    = module.eks.oidc_issuer

  depends_on = [module.eks]
}

# ─────────────────────────────────────────
# RDS
# ─────────────────────────────────────────
module "rds" {
  source = "../../modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id     = module.eks.node_security_group_id
  db_username        = var.db_username
  db_password        = var.db_password
  cluster_name       = var.cluster_name
}

# ─────────────────────────────────────────
# DYNAMODB
# ─────────────────────────────────────────
module "dynamodb" {
  source = "../../modules/dynamodb"

  cluster_name = var.cluster_name
}

# ─────────────────────────────────────────
# S3 + LAMBDA
# ─────────────────────────────────────────
module "s3_lambda" {
  source = "../../modules/s3-lambda"

  student_id           = var.student_id
  aws_account_id       = data.aws_caller_identity.current.account_id
  bedrock_dev_user_arn = module.iam.bedrock_dev_user_arn
}

# ─────────────────────────────────────────
# DATA SOURCES
# ─────────────────────────────────────────
data "aws_caller_identity" "current" {}
