output "config_recorder_name" {
  description = "Nombre del configuration recorder de AWS Config"
  value       = aws_config_configuration_recorder.recorder.name
}

output "config_bucket_name" {
  description = "Nombre del bucket S3 donde AWS Config guarda el historial"
  value       = aws_s3_bucket.config_bucket.bucket
}

output "config_rules" {
  description = "Nombres de las reglas de AWS Config creadas para IAM"
  value = [
    aws_config_config_rule.mfa_enabled.name,
    aws_config_config_rule.root_mfa_enabled.name,
    aws_config_config_rule.access_keys_rotated.name,
    aws_config_config_rule.iam_policy_no_statements_with_admin_access.name
  ]
}
