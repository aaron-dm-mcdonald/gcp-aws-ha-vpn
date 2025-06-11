output "network_id" {
  description = "ID of the created VPC network"
  value       = google_compute_network.main.id
}

output "network_name" {
  description = "Name of the created VPC network"
  value       = google_compute_network.main.name
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = google_compute_subnetwork.hqinternal.id
}

output "subnet_name" {
  description = "Name of the created subnet"
  value       = google_compute_subnetwork.hqinternal.name
}


