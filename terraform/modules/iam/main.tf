# ─────────────────────────────────────────
# EKS CLUSTER ROLE
# ─────────────────────────────────────────
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ─────────────────────────────────────────
# EKS NODE GROUP ROLE
# ─────────────────────────────────────────
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ecr_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "node_cloudwatch_policy" {
  role       = aws_iam_role.node.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# ─────────────────────────────────────────
# BEDROCK-DEV-VIEW IAM USER
# ─────────────────────────────────────────
resource "aws_iam_user" "bedrock_dev" {
  name = "bedrock-dev-view"

  tags = {
    Purpose = "Developer read-only access for grading"
  }
}

resource "aws_iam_user_login_profile" "bedrock_dev" {
  user                    = aws_iam_user.bedrock_dev.name
  password_reset_required = false
}

resource "aws_iam_access_key" "bedrock_dev" {
  user = aws_iam_user.bedrock_dev.name
}

resource "aws_iam_user_policy_attachment" "bedrock_dev_readonly" {
  user       = aws_iam_user.bedrock_dev.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_user_policy" "bedrock_dev_s3" {
  name = "bedrock-dev-s3-putobject"
  user = aws_iam_user.bedrock_dev.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "s3:PutObject"
      Resource = "arn:aws:s3:::bedrock-assets-altsoe0253240/*"
    }]
  })
}

# ─────────────────────────────────────────
# AWS LOAD BALANCER CONTROLLER PERMISSION PATCH
# ─────────────────────────────────────────
resource "aws_iam_role_policy" "lbc_network_discovery_patch" {
  name = "lbc-network-discovery-patch"
  # Target the exact role name from your cluster error logs
  role = "${var.cluster_name}-lbc-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeRouteTables",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeAccountAttributes"
        ],
        Resource = "*"
      }
    ]
  })
}