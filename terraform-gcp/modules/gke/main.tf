resource "google_container_cluster" "primary" {
  name               = var.cluster_name
  location           = var.region
  network            = var.network
  subnetwork         = var.subnetwork
  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

output "endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "master_auth" {
  value = google_container_cluster.primary.master_auth
}