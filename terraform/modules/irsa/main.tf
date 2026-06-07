# ─────────────────────────────────────────
# AWS LOAD BALANCER CONTROLLER — IRSA ROLE
# ─────────────────────────────────────────
data "aws_iam_policy_document" "lbc_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_issuer}"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lbc" {
  name               = "${var.cluster_name}-lbc-role"
  assume_role_policy = data.aws_iam_policy_document.lbc_assume_role.json
}

resource "aws_iam_policy" "lbc" {
  name   = "${var.cluster_name}-lbc-policy"
  policy = file("${path.module}/lbc-policy.json")
}

resource "aws_iam_role_policy_attachment" "lbc" {
  role       = aws_iam_role.lbc.name
  policy_arn = aws_iam_policy.lbc.arn
}

# ─────────────────────────────────────────
# CLOUDWATCH OBSERVABILITY — IRSA ROLE
# ─────────────────────────────────────────
data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${var.oidc_issuer}"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer}:sub"
      values   = ["system:serviceaccount:amazon-cloudwatch:cloudwatch-agent"]
    }
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "${var.cluster_name}-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
