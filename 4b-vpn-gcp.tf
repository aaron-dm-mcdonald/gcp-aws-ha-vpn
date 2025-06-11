locals {
  # Public IP addresses of the AWS VPN tunnel endpoints.
  # These are used by GCP to connect to the AWS side via External VPN Gateway interfaces.
  aws_tunnel_addresses = [
    aws_vpn_connection.vpn_conn[0].tunnel1_address,  # Tunnel 1 public IP (AWS side)
    aws_vpn_connection.vpn_conn[0].tunnel2_address   # Tunnel 2 public IP (AWS side)
  ]

  # Internal IP addresses on the Customer Gateway (CGW) side of the IPsec tunnels.
  # GCP uses these as its BGP interface IPs (i.e., GCP's local BGP IPs).
  aws_inside_cgw_addresses = [
    aws_vpn_connection.vpn_conn[0].tunnel1_cgw_inside_address,  # Tunnel 1 CGW inside IP (GCP BGP peer)
    aws_vpn_connection.vpn_conn[0].tunnel2_cgw_inside_address   # Tunnel 2 CGW inside IP (GCP BGP peer)
  ]

  # Internal IP addresses on the AWS Virtual Private Gateway (VGW) or Transit Gateway (TGW) side.
  # These are the remote BGP peer IPs that GCP connects to via Cloud Router.
  aws_inside_vgw_addresses = [
    aws_vpn_connection.vpn_conn[0].tunnel1_vgw_inside_address,  # Tunnel 1 VGW inside IP (AWS BGP peer)
    aws_vpn_connection.vpn_conn[0].tunnel2_vgw_inside_address   # Tunnel 2 VGW inside IP (AWS BGP peer)
  ]
}

######

resource "google_compute_ha_vpn_gateway" "gwy" {
  name    = "${var.name}-ha-vpn-gwy"
  network = module.gcp_network.network_id # GCP VPC to attach to
  region = var.gcp_config.region
}

resource "google_compute_external_vpn_gateway" "ext_gwy" {
  name            = "${var.name}-ext-vpn-gwy"
  redundancy_type = "TWO_IPS_REDUNDANCY"

  dynamic "interface" {
    for_each = [0, 1]
    content {
      id         = interface.value
      ip_address = local.aws_tunnel_addresses[interface.value]
    }
  }
}

resource "google_compute_router" "router" {
  name    = "${var.name}-router"
  network = module.gcp_network.network_id # GCP VPC to attach to
  region = var.gcp_config.region

  bgp {
    asn            = var.gcp_router_asn
    advertise_mode = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_vpn_tunnel" "tunnel" {
  count                           = 2

  name                            = "${var.name}-tunnel-${count.index}"
  shared_secret                   = var.shared_secret
  peer_external_gateway           = google_compute_external_vpn_gateway.ext_gwy.name
  peer_external_gateway_interface = count.index
  region                          = var.gcp_config.region
  router                          = google_compute_router.router.name
  ike_version                     = 2
  vpn_gateway                     = google_compute_ha_vpn_gateway.gwy.id
  vpn_gateway_interface           = count.index
}

resource "google_compute_router_interface" "interface" {
  count     = 2
  name      = "${var.name}-interface-${count.index}"
  router    = google_compute_router.router.name
  region    = var.gcp_config.region
  ip_range  = "${local.aws_inside_cgw_addresses[count.index]}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel[count.index].name
}

resource "google_compute_router_peer" "peer" {
  count            = 2
  name             = "${var.name}-peer-${count.index}"
  interface        = google_compute_router_interface.interface[count.index].name
  peer_asn         = var.aws_router_asn
  ip_address       = local.aws_inside_cgw_addresses[count.index]
  peer_ip_address  = local.aws_inside_vgw_addresses[count.index]
  router           = google_compute_router.router.name
  region           = var.gcp_config.region
}


resource "google_compute_firewall" "allow_bgp_udp_icmp" {
  name    = "${var.name}-allow-bgp-udp-icmp"
  network = module.gcp_network.network_id # GCP VPC to attach to

  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }

  allow {
    protocol = "icmp"
  }

  direction     = "INGRESS"
  source_ranges = [ "0.0.0.0/0"]
  priority      = 1000

 
}