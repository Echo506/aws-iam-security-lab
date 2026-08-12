# Modulo 3 - Roles IAM y AssumeRole (acceso temporal, sin credenciales de larga duracion)
#
# Objetivo pedagogico: eliminar el uso de access keys estaticas para acceso
# entre cuentas o entre servicios, usando roles que se asumen temporalmente.

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
# Rol de EC2 con acceso limitado a S3 (usando instance profile, sin keys)
# ---------------------------------------------------------------------------
resource "aws_iam_role" "ec2_s3_readonly_role" {
  name = "ec2-s3-readonly-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "ec2.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "ec2_s3_readonly_policy" {
  name = "ec2-s3-readonly-policy"
  role = aws_iam_role.ec2_s3_readonly_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ReadOnlyS3",
        Effect   = "Allow",
        Action   = ["s3:GetObject", "s3:ListBucket"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_s3_readonly_profile" {
  name = "ec2-s3-readonly-profile"
  role = aws_iam_role.ec2_s3_readonly_role.name
}

# ---------------------------------------------------------------------------
# Rol de acceso entre cuentas (cross-account), con condicion de External ID
# ---------------------------------------------------------------------------
resource "aws_iam_role" "cross_account_auditor_role" {
  name = "cross-account-auditor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { AWS = var.trusted_account_arn },
        Action    = "sts:AssumeRole",
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  max_session_duration = 3600
  tags                  = var.tags
}

resource "aws_iam_role_policy" "cross_account_auditor_policy" {
  name = "cross-account-auditor-policy"
  role = aws_iam_role.cross_account_auditor_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ReadOnlyAudit",
        Effect   = "Allow",
        Action   = [
          "iam:List*",
          "iam:Get*",
          "cloudtrail:LookupEvents",
          "cloudtrail:DescribeTrails"
        ],
        Resource = "*"
      }
    ]
  })
}
