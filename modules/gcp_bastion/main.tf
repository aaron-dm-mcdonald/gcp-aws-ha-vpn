resource "google_compute_firewall" "ssh" {
  name    = "${var.name}-allow-ssh"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}


resource "google_compute_firewall" "ping" {
  name    = "${var.name}-allow-ping"
  network = var.network

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_instance" "bastion" {
  name         = var.name
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
    }
  }

  network_interface {
    subnetwork = var.subnetwork
    access_config {} # Assigns a public IP
  }


}

