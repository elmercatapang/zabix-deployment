# Module: vpc

Creates a VPC with public subnets, an Internet Gateway, and route tables.

## Resources Created

| Resource | Terraform ID | Name (tag) | Description |
|---|---|---|---|
| `aws_vpc` | `this` | `<name>-vpc` | VPC with DNS support and DNS hostnames enabled |
| `aws_internet_gateway` | `this` | `<name>-igw` | IGW attached to the VPC |
| `aws_subnet` | `public[n]` | `<name>-public-<az>` | One public subnet per entry in `public_subnets` |
| `aws_route_table` | `public` | `<name>-public-rt` | Route table with `0.0.0.0/0 → IGW` |
| `aws_route_table_association` | `public[n]` | — | Associates each subnet with the public route table |

## Variables

| Variable | Type | Default | Description |
|---|---|---|---|
| `name` | `string` | — | Name prefix applied to all resource tags |
| `vpc_cidr` | `string` | — | CIDR block for the VPC |
| `public_subnets` | `list(string)` | — | List of subnet CIDRs (one per AZ) |
| `azs` | `list(string)` | — | Availability zones matching `public_subnets` |
| `tags` | `map(string)` | `{}` | Additional tags merged onto all resources |

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `public_subnet_ids` | List of public subnet IDs |

## Values per Environment

| | Sandbox | Production |
|---|---|---|
| `name` | `zabbix-sandbox` | `zabbix-prod` |
| `vpc_cidr` | `172.16.0.0/16` | `172.17.0.0/16` |
| `public_subnets` | `172.16.1.0/24`, `172.16.2.0/24` | `172.17.1.0/24`, `172.17.2.0/24` |
| `azs` | `us-east-1a`, `us-east-1b` | `us-east-1a`, `us-east-1b` |
