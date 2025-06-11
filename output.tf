output "aws_bastion" {
  value =  {
    ssh_command = module.aws_bastion.ssh_command
    ec2_instance_private_ip = module.aws_bastion.private_ip
    ec2_instance_public_ip = module.aws_bastion.public_ip
    }
 
}

output "gcp_bastion" {
  value = {
    ssh_command = module.gcp_bastion.ssh_command
    vm_internal_ip = module.gcp_bastion.internal_ip
    vm_external_ip = module.gcp_bastion.external_ip
    }
}

output "vpn_gateway_ips" {
  description = "Public IPs of AWS VPN tunnels and GCP VPN gateway"

  value = {
    aws_tunnels = flatten([
      for vpn_conn in aws_vpn_connection.vpn_conn : [
        vpn_conn.tunnel1_address,
        vpn_conn.tunnel2_address,
      ]
    ])
    gcp_gateway_ips = [
      for i in range(length(google_compute_ha_vpn_gateway.gwy.vpn_interfaces)) : google_compute_ha_vpn_gateway.gwy.vpn_interfaces[i].ip_address
    ]
  }
}
