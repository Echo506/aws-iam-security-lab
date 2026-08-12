output "cloudtrail_bucket_name" {
  description = "Nombre del bucket S3 que almacena los logs de CloudTrail"
  value       = aws_s3_bucket.cloudtrail_logs.id
}

output "cloudtrail_arn" {
  description = "ARN del trail de CloudTrail creado"
  value       = aws_cloudtrail.main_trail.arn
}

output "iam_policy_changes_alarm_name" {
  description = "Nombre de la alarma de CloudWatch que notifica cambios en politicas IAM"
  value       = aws_cloudwatch_metric_alarm.iam_policy_changes_alarm.alarm_name
}
