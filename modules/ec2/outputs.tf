output "instance_id" {
  value = aws_instance.zabbix.id
}

output "public_ip" {
  value = aws_eip.zabbix.public_ip
}

output "private_ip" {
  value = aws_instance.zabbix.private_ip
}

output "private_key_file" {
  value = local_sensitive_file.private_key.filename
}
