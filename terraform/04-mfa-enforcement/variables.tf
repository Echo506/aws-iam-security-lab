variable "aws_region" {
  description = "Region de AWS para el provider"
  type        = string
  default     = "us-east-1"
}

variable "groups_requiring_mfa" {
  description = "Lista de nombres de grupos IAM existentes a los que se les debe exigir MFA (por ejemplo, los grupos creados en el modulo 01: readonly-auditors, developers)"
  type        = list(string)
  default     = []
}
