# Modulo 5 - Auditoria centralizada con CloudTrail
#
# Objetivo pedagogico: registrar TODA la actividad de la cuenta (quien hizo
# que, cuando y desde donde) en un bucket S3 protegido, y generar alertas
# ante cambios sensibles en IAM.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

# ---------------------------------------------------------------------------
# Bucket S3 para almacenar los logs de CloudTrail (con cifrado y bloqueo
# de acceso publico)
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = var.cloudtrail_bucket_name
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_logs_block" {
  bucket                  = aws_s3_bucket.cloudtrail_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail_logs_sse" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudtrail_logs_versioning" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "cloudtrail_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail_logs.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket_policy.json
}

# ---------------------------------------------------------------------------
# Trail de CloudTrail: registra todos los eventos de gestion (management
# events) de la cuenta, incluyendo llamadas a la API de IAM
# ---------------------------------------------------------------------------
resource "aws_cloudtrail" "main_trail" {
  name                          = "aws-iam-lab-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs_policy]
}

# ---------------------------------------------------------------------------
# Grupo de CloudWatch Logs y metric filter para alertar sobre cambios
# sensibles en politicas IAM (ejemplo: CreatePolicy, DeletePolicy, etc.)
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  name              = "/aws-iam-lab/cloudtrail"
  retention_in_days = 90
}

resource "aws_cloudwatch_log_metric_filter" "iam_policy_changes" {
  name           = "IAMPolicyChanges"
  log_group_name = aws_cloudwatch_log_group.cloudtrail_log_group.name
  pattern        = "{ ($.eventSource = \"iam.amazonaws.com\") && (($.eventName = \"Put*Policy\") || ($.eventName = \"AttachRolePolicy\") || ($.eventName = \"AttachUserPolicy\") || ($.eventName = \"AttachGroupPolicy\") || ($.eventName = \"CreatePolicy\") || ($.eventName = \"DeletePolicy\")) }"

  metric_transformation {
    name      = "IAMPolicyChangeCount"
    namespace = "AWSIAMLab"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "iam_policy_changes_alarm" {
  alarm_name          = "iam-policy-changes-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.iam_policy_changes.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.iam_policy_changes.metric_transformation[0].namespace
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Se detecto un cambio en politicas IAM (creacion, adjuncion o eliminacion)"
  treat_missing_data  = "notBreaching"
}
