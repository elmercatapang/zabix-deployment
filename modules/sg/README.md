# Module: sg

Creates the Zabbix server security group with all required ingress and egress rules.

## Resources Created

| Resource | Terraform ID | Name (tag) | Description |
|---|---|---|---|
| `aws_security_group` | `zabbix` | `<name>-zabbix-sg` | Security group attached to the Zabbix EC2 instance |

## Ingress Rules

| Port | Protocol | Source | Purpose |
|---|---|---|---|
| 80 | TCP | `allowed_cidrs` | Zabbix web UI (HTTP) |
| 443 | TCP | `allowed_cidrs` | Zabbix web UI (HTTPS) |
| 22 | TCP | `ssh_cidrs` | SSH admin access |
| 10051 | TCP | `agent_cidrs` | Zabbix **active** agents (agents connect to server) |
| 10050 | TCP | `agent_cidrs` | Zabbix **passive** checks (server polls agents) |
| ICMP all | ICMP | `vpc_cidr` | Ping within the VPC |

## Egress Rules

| Port | Protocol | Destination | Purpose |
|---|---|---|---|
| All | All | `0.0.0.0/0` | Unrestricted outbound (package downloads, agent polling, alerts) |

## Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name prefix for the security group |
| `vpc_id` | `string` | — | VPC to create the security group in |
| `vpc_cidr` | `string` | — | VPC CIDR; used to restrict ICMP to internal traffic |
| `allowed_cidrs` | `list(string)` | `["0.0.0.0/0"]` | CIDRs allowed to reach the web UI on ports 80/443 |
| `ssh_cidrs` | `list(string)` | — | CIDRs allowed SSH access (port 22) |
| `agent_cidrs` | `list(string)` | `["0.0.0.0/0"]` | CIDRs for Zabbix agent traffic (ports 10050/10051) |
| `tags` | `map(string)` | `{}` | Tags merged onto the security group |

## Outputs

| Output | Description |
|---|---|
| `security_group_id` | ID of the created security group |

## Values per Environment

| | Sandbox | Production |
|---|---|---|
| `name` | `zabbix-sandbox` | `zabbix-prod` |
| `vpc_cidr` | `172.16.0.0/16` | `172.17.0.0/16` |
| `allowed_cidrs` | `var.web_ui_allowed_cidrs` (tfvars) | `var.web_ui_allowed_cidrs` (tfvars) |
| `ssh_cidrs` | `var.ssh_allowed_cidrs` (tfvars) | `var.ssh_allowed_cidrs` (tfvars) |
| `agent_cidrs` | `0.0.0.0/0` | `0.0.0.0/0` |
