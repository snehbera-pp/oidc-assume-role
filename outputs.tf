output "role_arn" {
  value = aws_iam_role.github_oidc.arn
}

output "bucket_name" {
  value = aws_s3_bucket.demo.id
}