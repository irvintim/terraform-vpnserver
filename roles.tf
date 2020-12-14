data "aws_iam_policy_document" "awsvpn_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter",
      "ssm:GetParametersByPath"
    ]
    resources = ["arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.company_name}/awsvpn/${local.ssm_environment}/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "sns:Publish",
      "ec2:DetachNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
      "ec2:AttachNetworkInterface",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListObjects"
    ]
    resources = [
      "arn:aws:s3:::${var.company_name}-instance-config-awsvpn-${var.environment}/*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.company_name}-instance-config-awsvpn-${var.environment}"
    ]
  }
}

data "aws_iam_policy_document" "awsvpn_role" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_policy" "awsvpn_policy" {
  name        = "${var.environment}-awsvpn-policy"
  description = "AWSVPN-Instance Policy for ${var.environment}"

  policy = data.aws_iam_policy_document.awsvpn_policy.json
}

resource "aws_iam_role" "awsvpn_role" {
  name                  = "${var.environment}-awsvpn-role"
  assume_role_policy    = data.aws_iam_policy_document.awsvpn_role.json
  force_detach_policies = true
  tags                  = merge(local.global_tags)
}

data "aws_iam_policy" "CloudWatchAgentServerPolicy" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "awsvpn-cwagent-role-policy-attach" {
  role       = aws_iam_role.awsvpn_role.name
  policy_arn = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn
}

resource "aws_iam_role_policy_attachment" "awsvpn-manual-role-policy-attach" {
  role       = aws_iam_role.awsvpn_role.name
  policy_arn = aws_iam_policy.awsvpn_policy.arn
}

resource "aws_iam_instance_profile" "awsvpn_profile" {
  name = "${var.environment}-awsvpn-profile"
  role = aws_iam_role.awsvpn_role.name
}
