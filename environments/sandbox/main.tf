module "vpc" {
  source = "../../modules/vpc"

  name           = "zabbix-sandbox"
  vpc_cidr       = "172.16.0.0/16"
  public_subnets = ["172.16.1.0/24", "172.16.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
  tags           = local.tags
}

module "sg" {
  source = "../../modules/sg"

  name          = "zabbix-sandbox"
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = "172.16.0.0/16"
  allowed_cidrs = var.web_ui_allowed_cidrs
  ssh_cidrs     = var.ssh_allowed_cidrs
  agent_cidrs   = ["0.0.0.0/0"]
  tags          = local.tags
}

module "ec2" {
  source = "../../modules/ec2"

  name              = "sandbox"
  subnet_id         = module.vpc.public_subnet_ids[0]
  security_group_id = module.sg.security_group_id
  instance_type     = "t3.medium"
  root_volume_size  = 30
  db_password       = var.db_password
  tags              = local.tags
}
