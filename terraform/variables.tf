variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for all resources."
  type        = string
  default     = "fra1"
}

variable "vpc_ip_range" {
  description = "Private network range."
  type        = string
  default     = "10.20.0.0/16"
}

variable "image" {
  description = "Operating system image for web servers."
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "droplet_size" {
  description = "DigitalOcean Droplet size for web servers."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "application_port" {
  description = "Port where the application listens on web servers."
  type        = number
  default     = 3000
}

variable "ssh_key_fingerprints" {
  description = "Existing DigitalOcean SSH key fingerprints for web servers."
  type        = list(string)
  default     = []
}

variable "trusted_ssh_sources" {
  description = "CIDR blocks allowed to connect to web servers by SSH."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "database_size" {
  description = "DigitalOcean managed PostgreSQL size."
  type        = string
  default     = "db-s-1vcpu-1gb"
}

variable "postgres_version" {
  description = "PostgreSQL version for managed database."
  type        = string
  default     = "16"
}

variable "database_name" {
  description = "Application database name."
  type        = string
  default     = "redmine"
}

variable "database_user" {
  description = "Application database user."
  type        = string
  default     = "redmine"
}

variable "domain_name" {
  description = "Domain name for the self-signed HTTPS certificate."
  type        = string
  default     = "redmine.example.com"
}
