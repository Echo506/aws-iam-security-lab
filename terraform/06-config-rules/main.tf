# Modulo 6: Deteccion continua con AWS Config Rules
#
# Objetivo: complementar la auditoria manual del Modulo 5 con reglas
# administradas de AWS Config que evaluan de forma continua el
# cumplimiento de buenas practicas de IAM (MFA, politicas permisivas,
# rotacion de credenciales, uso de root).

terraform {
  required_version = ">= 1.5.0"

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

# Bucket S3 donde AWS Config almacena el historial de configuracion.
resource "aws_s3_bucket" "config_bucket" {
  bucket        = "${var.project_prefix}-config-bucket-${var.account_suffix}"
  force_destroy = true

  tags = {
    Proyecto = "aws-iam-security-lab"
    Modulo   = "06-config-rules"
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket_block" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Rol que AWS Config asume para grabar la configuracion de recursos.
resource "aws_iam_role" "config_role" {
  name = "${var.project_prefix}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Proyecto = "aws-iam-security-lab"
    Modulo   = "06-config-rules"
  }
}

resource "aws_iam_role_policy_attachment" "config_role_managed" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_iam_role_policy" "config_role_s3" {
  name = "${var.project_prefix}-config-s3-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl"
        ]
        Resource = [
          aws_s3_bucket.config_bucket.arn,
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      }
    ]
  })
}

# Recorder: define que graba AWS Config (todos los recursos soportados).
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.project_prefix}-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "channel" {
  name           = "${var.project_prefix}-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.channel]
}

# Reglas administradas por AWS enfocadas en higiene de IAM.
resource "aws_config_config_rule" "mfa_enabled" {
  name = "${var.project_prefix}-iam-user-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "root_mfa_enabled" {
  name = "${var.project_prefix}-root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "access_keys_rotated" {
  name = "${var.project_prefix}-access-keys-rotated"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  input_parameters = jsonencode({
    maxAccessKeyAge = "90"
  })

  depends_on = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_config_rule" "iam_policy_no_statements_with_admin_access" {
  name = "${var.project_prefix}-iam-policy-no-admin-access"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}
