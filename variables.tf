variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for the demo"
}

variable "role_name" {
  type    = string
  default = "github-oidc-demo-role-tf"
}

variable "github_sub_claims" {
  type        = list(string)
  description = "Exact sub values allowed to assume the role"
}