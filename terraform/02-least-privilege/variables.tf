variable "aws_region" {
  description = "Region de AWS para el provider"
  type        = string
  default     = "us-east-1"
}

variable "logs_bucket_name" {
  description = "Nombre del bucket S3 que contiene los logs, usado en la politica de minimo privilegio"
  type        = string
  default     = "aws-iam-lab-logs-bucket-CHANGE-ME"
}
