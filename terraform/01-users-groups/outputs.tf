output "readonly_auditors_group_name" {
  description = "Nombre del grupo de auditores de solo lectura"
  value       = aws_iam_group.readonly_auditors.name
}

output "developers_group_name" {
  description = "Nombre del grupo de desarrolladores"
  value       = aws_iam_group.developers.name
}

output "example_auditor_user_name" {
  description = "Nombre del usuario de ejemplo (si fue creado)"
  value       = var.create_example_user ? aws_iam_user.example_auditor[0].name : null
}
