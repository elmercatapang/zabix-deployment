resource "aws_security_group" "zabbix" {
  name        = "${var.name}-zabbix-sg"
  description = "Zabbix server security group"
  vpc_id      = var.vpc_id

  # Web UI
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_cidrs
  }

  # Zabbix active agent connections (agents initiate to server port 10051)
  ingress {
    description = "Zabbix active agent"
    from_port   = 10051
    to_port     = 10051
    protocol    = "tcp"
    cidr_blocks = var.agent_cidrs
  }

  # Zabbix passive checks (server polls agents on 10050) - outbound handled below
  ingress {
    description = "Zabbix passive agent"
    from_port   = 10050
    to_port     = 10050
    protocol    = "tcp"
    cidr_blocks = var.agent_cidrs
  }

  # ICMP within VPC
  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-zabbix-sg" })
}
