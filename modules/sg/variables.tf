variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "allowed_cidrs" {
  description = "CIDRs allowed to access the Zabbix web UI"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_cidrs" {
  description = "CIDRs allowed SSH access"
  type        = list(string)
}

variable "agent_cidrs" {
  description = "CIDRs for Zabbix agent communication (on-prem + VPC)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
