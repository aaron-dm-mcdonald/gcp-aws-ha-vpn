module "aws_bastion" {
  source    = "./modules/aws_bastion"
  vpc_id    = module.aws_network.vpc_id
  subnet_id = module.aws_network.public_subnet_id
}

module "gcp_bastion" {
  source     = "./modules/gcp_bastion"
  name       = "${var.name}-bastion"
  region     = var.gcp_config.region
  zone       = "${var.gcp_config.region}-a"
  network    = module.gcp_network.network_name
  subnetwork = module.gcp_network.subnet_name
}
