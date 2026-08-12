variable "aws_region" {
  description = "Region de AWS para el provider"
  type        = string
  default     = "us-east-1"
}

variable "trusted_account_arn" {
  description = "ARN de la cuenta o rol de confianza que puede asumir el rol cross-account (ejemplo: arn:aws:iam::123456789012:root)"
  type        = string
  default     = "arn:aws:iam::123456789012:root"
}

variable "external_id" {
  description = "External ID unico usado como proteccion adicional contra el problema de 'confused deputy' al asumir el rol cross-account"
  type        = string
  default     = "CHANGE-ME-unique-external-id"
}

variable "tags" {
  description = "Tags comunes para los roles creados en este modulo"
  type        = map(string)
  default = {
    Project = "aws-iam-security-lab"
    Module  = "03-roles-assume-role"
  }
}
