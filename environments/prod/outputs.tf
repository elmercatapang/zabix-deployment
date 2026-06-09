output "zabbix_public_ip" {
  description = "Public IP of the Zabbix server"
  value       = module.ec2.public_ip
}

output "zabbix_url" {
  description = "Zabbix web UI URL"
  value       = "http://${module.ec2.public_ip}/zabbix"
}

output "ssh_command" {
  description = "SSH command to connect to the Zabbix server"
  value       = "ssh -i zabbix-prod.pem ubuntu@${module.ec2.public_ip}"
}

output "private_key_file" {
  value = module.ec2.private_key_file
}
