variable "db_password" {
  description = "PostgreSQL password for the Zabbix database user"
  type        = string
  sensitive   = true
}

variable "web_ui_allowed_cidrs" {
  description = "CIDRs allowed to reach the Zabbix web UI (ports 80/443)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs allowed SSH access to the Zabbix server"
  type        = list(string)
}
