output "ec2_s3_readonly_role_arn" {
  description = "ARN del rol IAM para instancias EC2 con acceso de solo lectura a S3"
  value       = aws_iam_role.ec2_s3_readonly_role.arn
}

output "ec2_instance_profile_name" {
  description = "Nombre del instance profile para adjuntar a instancias EC2"
  value       = aws_iam_instance_profile.ec2_s3_readonly_profile.name
}

output "cross_account_auditor_role_arn" {
  description = "ARN del rol cross-account para auditoria de solo lectura"
  value       = aws_iam_role.cross_account_auditor_role.arn
}
