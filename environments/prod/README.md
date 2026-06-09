# Environment: Production

Production deployment of the Zabbix monitoring server. Deploy only after sandbox has been validated.

## Account Details

| Field | Value |
|---|---|
| AWS Profile | `infra-secops` |
| Region | `us-east-1` |

## Network

| Resource | Value |
|---|---|
| VPC CIDR | `172.17.0.0/16` |
| Public Subnet A | `172.17.1.0/24` — `us-east-1a` |
| Public Subnet B | `172.17.2.0/24` — `us-east-1b` |
| Zabbix server deployed in | `us-east-1a` (`172.17.1.0/24`) |

## Compute

| Resource | Value |
|---|---|
| Instance type | `t3.large` (2 vCPU / 8 GB RAM) |
| OS | Ubuntu 22.04 LTS |
| Root volume | 50 GB gp3, encrypted |
| Public IP | Elastic IP (assigned at apply) |
| Key pair | `prod-zabbix-key` |
| Private key file | `zabbix-prod.pem` (written locally, gitignored) |

## Security Group Rules

| Direction | Port | Protocol | Source/Dest |
|---|---|---|---|
| Ingress | 80 | TCP | `web_ui_allowed_cidrs` (tfvars) |
| Ingress | 443 | TCP | `web_ui_allowed_cidrs` (tfvars) |
| Ingress | 22 | TCP | `ssh_allowed_cidrs` (tfvars) |
| Ingress | 10051 | TCP | `0.0.0.0/0` (active agents) |
| Ingress | 10050 | TCP | `0.0.0.0/0` (passive checks) |
| Ingress | ICMP | ICMP | `172.17.0.0/16` (VPC only) |
| Egress | All | All | `0.0.0.0/0` |

## Tags

| Key | Value |
|---|---|
| `Project` | `zabbix` |
| `Environment` | `prod` |
| `ManagedBy` | `terraform` |

## Terraform Variables (terraform.tfvars)

| Variable | Type | Required | Description |
|---|---|---|---|
| `db_password` | string | Yes | PostgreSQL password for the `zabbix` DB user |
| `ssh_allowed_cidrs` | list(string) | Yes | Your IP(s) in CIDR notation for SSH access |
| `web_ui_allowed_cidrs` | list(string) | No (default `0.0.0.0/0`) | CIDRs allowed to reach the web UI |

Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in values. Never commit `terraform.tfvars`.

## Deploy

```bash
cd environments/prod
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars
terraform init
terraform plan
terraform apply
```

## Outputs

| Output | Description |
|---|---|
| `zabbix_public_ip` | Elastic IP of the Zabbix server |
| `zabbix_url` | `http://<ip>/zabbix` |
| `ssh_command` | `ssh -i zabbix-prod.pem ubuntu@<ip>` |
| `private_key_file` | Local path to the `.pem` file |
