# Modulo 1 - Usuarios y grupos con permisos minimos
#
# Objetivo pedagogico: nunca asignar politicas directamente a un usuario.
# Siempre agrupar por funcion y asignar permisos al grupo.
#
# Este modulo crea dos grupos de ejemplo:
#   - readonly-auditors: solo lectura sobre S3 y IAM (para auditoria)
#   - developers: acceso limitado a un bucket S3 especifico de desarrollo

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

# ---------------------------------------------------------------------------
# Grupo: readonly-auditors
# ---------------------------------------------------------------------------
resource "aws_iam_group" "readonly_auditors" {
  name = "readonly-auditors"
}

resource "aws_iam_group_policy" "readonly_auditors_policy" {
  name  = "readonly-auditors-policy"
  group = aws_iam_group.readonly_auditors.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ReadOnlyS3",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      },
      {
        Sid    = "ReadOnlyIAMForAuditing",
        Effect = "Allow",
        Action = [
          "iam:ListUsers",
          "iam:ListGroups",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:GetUser",
          "iam:ListAttachedUserPolicies",
          "iam:ListMFADevices"
        ],
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Grupo: developers (acceso limitado a un bucket especifico de desarrollo)
# ---------------------------------------------------------------------------
resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_policy" "developers_policy" {
  name  = "developers-policy"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "DevBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::${var.dev_bucket_name}",
          "arn:aws:s3:::${var.dev_bucket_name}/*"
        ]
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Usuario de ejemplo (opcional, controlado por variable create_example_user)
# ---------------------------------------------------------------------------
resource "aws_iam_user" "example_auditor" {
  count = var.create_example_user ? 1 : 0
  name  = "lab-auditor-example"

  tags = {
    Project = "aws-iam-security-lab"
    Purpose = "training"
  }
}

resource "aws_iam_user_group_membership" "example_auditor_membership" {
  count    = var.create_example_user ? 1 : 0
  user     = aws_iam_user.example_auditor[0].name
  groups   = [aws_iam_group.readonly_auditors.name]
}
