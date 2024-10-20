terraform {
  required_providers {
    google = {
        source = "hashicorp/google"
        version = "5.36.0"
    }
  }
}

provider "google" {  
    project = var.project_name
    region = var.region
    credentials = var.credentials
}

resource "google_compute_instance" "default" {
   name = "my-instance"
   machine_type = "e2-medium"
   zone = var.zone
   network_interface {
    network = "default"
    access_config {
      # This will automatically assign an ephemeral IP address
    }
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata = {
    ssh-keys ="maodo:${file(var.public_key)}"
  }
  # Firewall rule for HTTP and HTTPS
}
 resource "google_compute_firewall" "default" {
    name = "allow-http-https"
    network = "default"
    allow {
      protocol = "tcp"
      ports = ["80","443","1012"]
    }
    allow {
      protocol = "tcp"
      ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"]
  }

# Output the ephemeral external IP of the instance
output "external_ip" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}