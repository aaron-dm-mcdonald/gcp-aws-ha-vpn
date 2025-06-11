output "ssh_command" {
  description = "SSH command to connect to the GCP bastion host using gcloud"
  value       = "gcloud compute ssh ${google_compute_instance.bastion.name} --zone=${var.zone}"
}

output "internal_ip" {
  description = "Internal IP address of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "external_ip" {
  description = "External (public) IP address of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}