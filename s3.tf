data "aws_s3_bucket" "flowlogs" {
  for_each = var.bucket_env_map
  bucket   = each.value
}
