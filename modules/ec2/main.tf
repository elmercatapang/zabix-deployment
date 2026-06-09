data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "zabbix" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "zabbix" {
  key_name   = "${var.name}-zabbix-key"
  public_key = tls_private_key.zabbix.public_key_openssh

  tags = var.tags
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.zabbix.private_key_pem
  filename        = "${path.root}/zabbix-${var.name}.pem"
  file_permission = "0600"
}

resource "aws_instance" "zabbix" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = aws_key_pair.zabbix.key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })

  tags = merge(var.tags, { Name = "${var.name}-zabbix-server" })
}

resource "aws_eip" "zabbix" {
  instance = aws_instance.zabbix.id
  domain   = "vpc"

  tags = merge(var.tags, { Name = "${var.name}-zabbix-eip" })
}
