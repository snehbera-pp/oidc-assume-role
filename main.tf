# 1. Existing GitHub OIDC provider (READ only, do not create)
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# 2. Demo bucket
resource "aws_s3_bucket" "demo" {
  bucket        = var.bucket_name
  force_destroy = true # demo only, Iis destroy bucket and remove files too
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket                  = aws_s3_bucket.demo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Trust policy: WHO can assume the role
data "aws_iam_policy_document" "trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = var.github_sub_claims
    }
  }
}

# 4. The role
resource "aws_iam_role" "github_oidc" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.trust.json
  max_session_duration = 3600
}

# 5. Permission policy: WHAT the role can do
data "aws_iam_policy_document" "s3_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.demo.arn]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:GetObject"]
    resources = ["${aws_s3_bucket.demo.arn}/*"]
  }
}

resource "aws_iam_role_policy" "s3_access" {
  name   = "s3-demo-access"
  role   = aws_iam_role.github_oidc.id
  policy = data.aws_iam_policy_document.s3_access.json
}

# Add variables to git repo which workflows used
resource "github_actions_variable" "role_arn" {
  repository    = "oidc-assume-role"
  variable_name = "AWS_ROLE_ARN"
  value         = aws_iam_role.github_oidc.arn
}

resource "github_actions_variable" "bucket" {
  repository    = "oidc-assume-role"
  variable_name = "AWS_BUCKET"
  value         = aws_s3_bucket.demo.id
}