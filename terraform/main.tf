terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.91.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

locals {
  project_name = "project-77"
  web_tag      = "${local.project_name}-web"

  web_servers = {
    web1 = "${local.project_name}-web-1"
    web2 = "${local.project_name}-web-2"
  }
}

resource "digitalocean_vpc" "default" {
  name     = "${local.project_name}-vpc"
  region   = var.region
  ip_range = var.vpc_ip_range
}

resource "digitalocean_droplet" "web" {
  for_each = local.web_servers

  name       = each.value
  image      = var.image
  region     = var.region
  size       = var.droplet_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.default.id
  ssh_keys   = var.ssh_key_fingerprints
  tags       = [local.web_tag]
}

resource "digitalocean_database_cluster" "postgres" {
  name                 = "${local.project_name}-postgres"
  engine               = "pg"
  version              = var.postgres_version
  size                 = var.database_size
  region               = var.region
  node_count           = 1
  private_network_uuid = digitalocean_vpc.default.id
}

resource "digitalocean_database_db" "app" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.database_name
}

resource "digitalocean_database_user" "app" {
  cluster_id = digitalocean_database_cluster.postgres.id
  name       = var.database_user
}

resource "digitalocean_database_firewall" "postgres" {
  cluster_id = digitalocean_database_cluster.postgres.id

  rule {
    type  = "tag"
    value = local.web_tag
  }
}

resource "tls_private_key" "load_balancer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "load_balancer" {
  private_key_pem = tls_private_key.load_balancer.private_key_pem

  subject {
    common_name  = var.domain_name
    organization = "Hexlet"
  }

  dns_names             = [var.domain_name]
  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
  ]
}

resource "digitalocean_certificate" "load_balancer" {
  name             = "${local.project_name}-self-signed"
  type             = "custom"
  private_key      = tls_private_key.load_balancer.private_key_pem
  leaf_certificate = tls_self_signed_cert.load_balancer.cert_pem
}

resource "digitalocean_loadbalancer" "web" {
  name                   = "${local.project_name}-lb"
  region                 = var.region
  vpc_uuid               = digitalocean_vpc.default.id
  redirect_http_to_https = true

  droplet_ids = [
    for droplet in digitalocean_droplet.web : droplet.id
  ]

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = var.application_port
  }

  forwarding_rule {
    entry_protocol   = "https"
    entry_port       = 443
    target_protocol  = "http"
    target_port      = var.application_port
    certificate_name = digitalocean_certificate.load_balancer.name
  }

  healthcheck {
    protocol                 = "http"
    port                     = var.application_port
    path                     = "/"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    healthy_threshold        = 2
    unhealthy_threshold      = 3
  }
}

resource "digitalocean_firewall" "web" {
  name = "${local.project_name}-web-firewall"

  droplet_ids = [
    for droplet in digitalocean_droplet.web : droplet.id
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.trusted_ssh_sources
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = tostring(var.application_port)
    source_load_balancer_uids = [digitalocean_loadbalancer.web.id]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = var.trusted_ssh_sources
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/../ansible/inventory.ini"
  file_permission = "0644"

  content = <<-EOF
[webservers]
%{for name, droplet in digitalocean_droplet.web~}
${name} ansible_host=${droplet.ipv4_address} ansible_host_private=${droplet.ipv4_address_private} ansible_user=root
%{endfor~}
  EOF
}
