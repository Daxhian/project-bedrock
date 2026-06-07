# Required by grading script — do not rename these outputs
output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "assets_bucket_name" {
  description = "S3 assets bucket name"
  value       = module.s3_lambda.assets_bucket_name
}

# Additional outputs
output "rds_mysql_endpoint" {
  value     = module.rds.mysql_endpoint
  sensitive = true
}

output "rds_postgres_endpoint" {
  value     = module.rds.postgres_endpoint
  sensitive = true
}

output "lbc_role_arn" {
  value = module.irsa.lbc_role_arn
}

output "cloudwatch_role_arn" {
  value = module.irsa.cloudwatch_role_arn
}

output "bedrock_dev_access_key_id" {
  value     = module.iam.bedrock_dev_access_key_id
  sensitive = true
}

output "bedrock_dev_secret_access_key" {
  value     = module.iam.bedrock_dev_secret_access_key
  sensitive = true
}
