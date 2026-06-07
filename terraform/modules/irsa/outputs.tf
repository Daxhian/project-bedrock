output "lbc_role_arn" {
  value = aws_iam_role.lbc.arn
}

output "cloudwatch_role_arn" {
  value = aws_iam_role.cloudwatch.arn
}
