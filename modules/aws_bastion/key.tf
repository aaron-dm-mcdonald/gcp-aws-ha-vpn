resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "bastion-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_file" {
  filename        = "${path.root}/private_key.pem" # Save key in root directory
  content         = tls_private_key.ssh_key.private_key_pem
  file_permission = "0600"
}