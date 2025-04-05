data "google_compute_instance" "example_instance" {
  name    = "my-vm"

  zone    = "us-central1-a"    # The zone to list instances from
}

output "instance_list" {
  value = data.google_compute_instance.example_instance
}
