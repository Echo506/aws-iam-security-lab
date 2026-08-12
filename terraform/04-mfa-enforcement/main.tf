# Modulo 4 - Enforcement de MFA (Multi-Factor Authentication)
#
# Objetivo pedagogico: denegar CASI todas las acciones a cualquier usuario
# que no haya iniciado sesion con MFA. Este es uno de los controles de
# seguridad de mayor impacto y menor costo en toda cuenta de AWS.

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
# Politica administrada: exige MFA para poder hacer casi cualquier cosa,
# excepto administrar el propio dispositivo MFA (para poder configurarlo
# la primera vez sin quedar bloqueado).
# ---------------------------------------------------------------------------
resource "aws_iam_policy" "require_mfa" {
  name        = "require-mfa-policy"
  description = "Deniega todas las acciones si el usuario no se autentico con MFA, salvo la gestion de su propio dispositivo MFA"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowViewAccountInfo",
        Effect = "Allow",
        Action = [
          "iam:GetAccountPasswordPolicy",
          "iam:ListVirtualMFADevices"
        ],
        Resource = "*"
      },
      {
        Sid    = "AllowManageOwnPasswordAndMFA",
        Effect = "Allow",
        Action = [
          "iam:ChangePassword",
          "iam:GetUser",
          "iam:CreateVirtualMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:ResyncMFADevice",
          "iam:ListMFADevices"
        ],
        Resource = [
          "arn:aws:iam::*:user/$${aws:username}",
          "arn:aws:iam::*:mfa/$${aws:username}"
        ]
      },
      {
        Sid       = "DenyAllExceptListedIfNoMFA",
        Effect    = "Deny",
        NotAction = [
          "iam:CreateVirtualMFADevice",
          "iam:EnableMFADevice",
          "iam:GetUser",
          "iam:ListMFADevices",
          "iam:ListVirtualMFADevices",
          "iam:ResyncMFADevice",
          "iam:ChangePassword",
          "iam:GetAccountPasswordPolicy",
          "sts:GetSessionToken"
        ],
        Resource = "*",
        Condition = {
          BoolIfExists = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Politica de contrasenas de la cuenta (buena practica complementaria a MFA)
# ---------------------------------------------------------------------------
resource "aws_iam_account_password_policy" "strict_password_policy" {
  minimum_password_length        = 14
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 5
}

# ---------------------------------------------------------------------------
# Adjuntar la politica de MFA a los grupos definidos en el modulo 01
# (referencia por nombre para mantener el modulo independiente/reutilizable)
# ---------------------------------------------------------------------------
resource "aws_iam_group_policy_attachment" "attach_mfa_to_group" {
  for_each   = toset(var.groups_requiring_mfa)
  group      = each.value
  policy_arn = aws_iam_policy.require_mfa.arn
}
