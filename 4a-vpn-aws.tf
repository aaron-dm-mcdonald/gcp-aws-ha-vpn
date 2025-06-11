locals {
  default_num_ha_vpn_interfaces = 2
}

# Create a Virtual Private Gateway (VGW)
resource "aws_vpn_gateway" "vgw" {
  vpc_id = module.aws_network.vpc_id

  tags = {
    Name = "${var.name}-vgw"
  }
}

# Attach the VGW to the VPC (can be automatic?)
resource "aws_vpn_gateway_attachment" "vgw_attachment" {
  vpc_id         = module.aws_network.vpc_id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

# Create a Customer Gateway (GCP side) for each HA VPN interface
resource "aws_customer_gateway" "gwy" {
  count      = local.default_num_ha_vpn_interfaces
  device_name = "${var.name}-gwy-${count.index}"
  bgp_asn     = var.gcp_router_asn
  type        = "ipsec.1"
  ip_address  = google_compute_ha_vpn_gateway.gwy.vpn_interfaces[count.index]["ip_address"]
}

# Create Site-to-Site VPN connections (one per HA pair)
resource "aws_vpn_connection" "vpn_conn" {
  count = var.num_tunnels / 2

  customer_gateway_id = aws_customer_gateway.gwy[count.index % 2].id
  # Selects Customer Gateway  by cycling through the two gateways (index 0 and 1)
  # so VPN connections alternate between the two GCP HA VPN interfaces.
  vpn_gateway_id        = aws_vpn_gateway.vgw.id
  type                  = "ipsec.1"
  tunnel1_preshared_key = var.shared_secret
  tunnel2_preshared_key = var.shared_secret

  tags = {
    Name = "${var.name}-vpn-connection"
  }
}

resource "aws_vpn_gateway_route_propagation" "public" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = module.aws_network.public_route_table_id
}

resource "aws_vpn_gateway_route_propagation" "private" {
  vpn_gateway_id = aws_vpn_gateway.vgw.id
  route_table_id = module.aws_network.private_route_table_id
}

resource "aws_security_group" "this" {
  name        = "${var.name}-sg"
  description = "Allow traffic from GCP subnet"
  vpc_id      = module.aws_network.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.gcp_config.subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}