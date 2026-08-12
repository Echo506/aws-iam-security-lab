variable "aws_region" {
  description = "Region de AWS donde se desplegara AWS Config"
  type        = string
  default     = "us-east-1"
}

variable "project_prefix" {
  description = "Prefijo usado para nombrar los recursos de este modulo"
  type        = string
  default     = "iam-lab"
}

variable "account_suffix" {
  description = "Sufijo unico (ej. account id o iniciales) para evitar colisiones de nombres de bucket S3, que son globales"
  type        = string
}
