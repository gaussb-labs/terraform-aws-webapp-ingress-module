resource "aws_s3_bucket" "alb_access_logs" {
  bucket = "${var.environment}-${var.alb_access_logs_bucket_name}"

  tags = {
    "Name"      = "${var.environment}_${var.alb_access_logs_bucket_name}"
    "ManagedBy" = local.managed_by
  }
}

resource "aws_s3_bucket_acl" "alb_access_logs_private" {
  bucket = aws_s3_bucket.alb_access_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_access_log_retention_policy" {
  bucket = aws_s3_bucket.alb_access_logs.id
  rule {
    id = "retain_logs_for_${var.alb_access_logs_expiry_days}_days"
    filter {
      prefix = var.alb_access_logs_prefix
    }
    expiration {
      days = var.alb_access_logs_expiry_days
    }
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "alb_access_log_access" {
  bucket = aws_s3_bucket.alb_access_logs.id
  policy = data.aws_iam_policy_document.alb_access_log.json
}

data "aws_iam_policy_document" "alb_access_log" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = [var.alb_aws_account_arn]
      type        = "AWS"
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.alb_access_logs.arn}/${var.alb_access_logs_prefix}/*"]
  }
}
