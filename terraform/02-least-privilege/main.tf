# Modulo 2 - Politicas de minimo privilegio
#
# Objetivo pedagogico: comparar una politica permisiva (mala practica)
# contra una politica de minimo privilegio (buena practica), y aplicar
# un permissions boundary para limitar el alcance maximo de un rol.

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
# EJEMPLO MALO (solo como referencia educativa, NO se crea en AWS)
# ---------------------------------------------------------------------------
# resource "aws_iam_policy" "bad_example_admin_everything" {
#   name = "bad-practice-full-access"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = "*"
#       Resource = "*"
#     }]
#   })
# }
# Por que es malo: otorga control total sobre TODOS los servicios de AWS.
# Cualquier credencial filtrada de este usuario compromete toda la cuenta.

# ---------------------------------------------------------------------------
# BUENA PRACTICA: politica de minimo privilegio para revisar logs en S3
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "least_privilege_log_reader" {
  name        = "least-privilege-log-reader"
  description = "Permite leer unicamente los logs bajo el prefijo logs/ de un bucket especifico"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "ListOnlyLogsPrefix",
        Effect   = "Allow",
        Action   = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::${var.logs_bucket_name}",
        Condition = {
          StringLike = {
            "s3:prefix" = ["logs/*"]
          }
        }
      },
      {
        Sid      = "ReadOnlyLogsObjects",
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "arn:aws:s3:::${var.logs_bucket_name}/logs/*"
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Permissions boundary: limite maximo de permisos para roles de aplicacion
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "app_permissions_boundary" {
  name        = "app-permissions-boundary"
  description = "Limite maximo de permisos que cualquier rol de aplicacion puede tener, sin importar que politicas se le adjunten despues"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "DenyIAMAndOrgManagement",
        Effect   = "Deny",
        Action   = [
          "iam:*",
          "organizations:*",
          "account:*"
        ],
        Resource = "*"
      },
      {
        Sid      = "AllowOnlyS3AndLogs",
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
