output "least_privilege_log_reader_arn" {
  description = "ARN de la politica de minimo privilegio para lectura de logs"
  value       = aws_iam_policy.least_privilege_log_reader.arn
}

output "app_permissions_boundary_arn" {
  description = "ARN del permissions boundary para roles de aplicacion"
  value       = aws_iam_policy.app_permissions_boundary.arn
}
