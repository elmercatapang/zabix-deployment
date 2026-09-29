variable "sender_email" {
  description = "Email address to verify as the SES sending identity"
  type        = string
}

variable "tags" {
  description = "Tags applied to SES-related resources"
  type        = map(string)
  default     = {}
}
