variable "aws_region" {
  description = "Region de AWS para el provider"
  type        = string
  default     = "us-east-1"
}

variable "cloudtrail_bucket_name" {
  description = "Nombre unico global del bucket S3 donde CloudTrail almacenara los logs"
  type        = string
  default     = "aws-iam-lab-cloudtrail-logs-CHANGE-ME"
}
