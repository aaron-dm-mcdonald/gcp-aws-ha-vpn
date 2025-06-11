variable "name" {
  type    = string
  default = "vpn-test"
}

variable "aws_config" {
  type = object({
    region                = string
    vpc_cidr              = string
    public_subnet_a_cidr  = string
    private_subnet_a_cidr = string
  })
  default = {
    region                = "us-east-2"
    vpc_cidr              = "10.10.0.0/16"
    public_subnet_a_cidr  = "10.10.1.0/24"
    private_subnet_a_cidr = "10.10.10.0/24"

  }
}

# Usage:
# cidr_block = var.aws_config.public_subnet_a_cidr


variable "gcp_config" {
  type = object({
    region      = string
    subnet_cidr = string
    project     = string
  })
  default = {
    region      = "us-central1"
    subnet_cidr = "10.100.10.0/24"
    project     = "ambient-topic-462623-t1"
  }
}

variable "num_tunnels" {
  type = number
  description = "Total number of VPN tunnels. Must be an even number for HA (minimum 4)."
  default     = 4

  validation {
    condition     = var.num_tunnels % 2 == 0
    error_message = "number of tunnels needs to be in multiples of 2."
  }

  validation {
    condition     = var.num_tunnels >= 4
    error_message = "minimum 4 tunnels required for high availability."
  }
}

variable "shared_secret" {
  type        = string
  description = "Pre-shared key (PSK) used to secure the VPN tunnels."
  sensitive   = true
  default     = "lizzo_dank"  
}

variable "shared_key_name" {
  type        = string
  description = "shared secret key."
  default     = "lizzo"
}

variable "gcp_router_asn" {
  type        = string
  description = "BGP Autonomous System Number (ASN) used by the GCP VPN router."
  default     = "65001"
}

variable "aws_router_asn" {
  type        = string
  description = "BGP ASN used by the AWS side VPN (Transit Gateway or VGW)."
  default     = "64512"
}
