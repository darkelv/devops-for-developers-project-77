output "load_balancer_ip" {
  description = "Public IP address of the load balancer."
  value       = digitalocean_loadbalancer.web.ip
}

output "load_balancer_https_url" {
  description = "HTTPS URL of the load balancer."
  value       = "https://${digitalocean_loadbalancer.web.ip}"
}

output "web_public_ips" {
  description = "Public IP addresses of web servers."
  value = {
    for name, droplet in digitalocean_droplet.web : name => droplet.ipv4_address
  }
}

output "database_host" {
  description = "Private host of the managed PostgreSQL cluster."
  value       = digitalocean_database_cluster.postgres.private_host
}

output "database_port" {
  description = "PostgreSQL port."
  value       = digitalocean_database_cluster.postgres.port
}

output "database_name" {
  description = "Application database name."
  value       = digitalocean_database_db.app.name
}

output "database_user" {
  description = "Application database user."
  value       = digitalocean_database_user.app.name
}

output "database_password" {
  description = "Application database password."
  value       = digitalocean_database_user.app.password
  sensitive   = true
}

output "ansible_inventory_path" {
  description = "Generated Ansible inventory."
  value       = local_file.ansible_inventory.filename
}
