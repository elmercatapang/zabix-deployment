variable "name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30
}

variable "db_name" {
  type    = string
  default = "zabbix"
}

variable "db_user" {
  type    = string
  default = "zabbix"
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
