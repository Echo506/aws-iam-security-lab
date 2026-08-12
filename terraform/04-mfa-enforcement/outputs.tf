output "require_mfa_policy_arn" {
  description = "ARN de la politica que exige MFA"
  value       = aws_iam_policy.require_mfa.arn
}
