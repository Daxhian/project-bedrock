output "cluster_role_arn" {
  value = aws_iam_role.cluster.arn
}

output "node_role_arn" {
  value = aws_iam_role.node.arn
}

output "bedrock_dev_user_arn" {
  value = aws_iam_user.bedrock_dev.arn
}

output "bedrock_dev_access_key_id" {
  value     = aws_iam_access_key.bedrock_dev.id
  sensitive = true
}

output "bedrock_dev_secret_access_key" {
  value     = aws_iam_access_key.bedrock_dev.secret
  sensitive = true
}

output "bedrock_dev_console_password" {
  value     = aws_iam_user_login_profile.bedrock_dev.password
  sensitive = true
}
