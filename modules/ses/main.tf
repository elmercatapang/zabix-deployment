resource "aws_ses_email_identity" "sender" {
  email = var.sender_email
}

resource "aws_iam_user" "smtp" {
  name = "zabbix-ses-smtp"
  path = "/system/"
  tags = var.tags
}

resource "aws_iam_access_key" "smtp" {
  user = aws_iam_user.smtp.name
}

data "aws_iam_policy_document" "send_email" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = [aws_ses_email_identity.sender.arn]
  }
}

resource "aws_iam_user_policy" "smtp_send" {
  name   = "ses-send-email"
  user   = aws_iam_user.smtp.name
  policy = data.aws_iam_policy_document.send_email.json
}
