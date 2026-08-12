variable "dev_bucket_name" {
  description = "Nombre del bucket S3 de desarrollo usado en las politicas de ejemplo"
  type        = string
  default     = "aws-iam-lab-dev-bucket-CHANGE-ME"
}

variable "create_example_user" {
  description = "Si es true, crea un usuario IAM de ejemplo (lab-auditor-example) para pruebas"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags comunes aplicadas a los recursos del modulo"
  type        = map(string)
  default = {
    Project = "aws-iam-security-lab"
    Module  = "01-users-groups"
  }
}
