output "ssh_command" {
  description = "SSH command to connect to the EC2 instance"
  value       = "ssh -i ${local_file.private_key_file.filename} ec2-user@${aws_instance.vm.public_ip}"
}

output "private_ip" {
  description = "Private IP address of the AWS instance"
  value       = aws_instance.vm.private_ip
}

output "public_ip" {
  description = "Public IP address of the AWS instance"
  value       = aws_instance.vm.public_ip
}
