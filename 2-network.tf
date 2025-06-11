module "aws_network" {
  source                = "./modules/aws_network"
  region                = var.aws_config.region
  vpc_cidr              = var.aws_config.vpc_cidr
  public_subnet_a_cidr  = var.aws_config.public_subnet_a_cidr
  private_subnet_a_cidr = var.aws_config.private_subnet_a_cidr
}

module "gcp_network" {
  source      = "./modules/gcp_network"
  region      = var.gcp_config.region
  subnet_cidr = var.gcp_config.subnet_cidr
}