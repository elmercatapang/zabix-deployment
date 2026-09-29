output "smtp_username" {
  description = "SMTP username (IAM access key ID) for Zabbix's Email media type"
  value       = aws_iam_access_key.smtp.id
}

output "smtp_password" {
  description = "SMTP password, derived from the IAM secret key via AWS's SigV4 conversion"
  value       = aws_iam_access_key.smtp.ses_smtp_password_v4
  sensitive   = true
}

output "smtp_server" {
  description = "SES SMTP endpoint for this region"
  value       = "email-smtp.us-east-1.amazonaws.com"
}
