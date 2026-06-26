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

    datadog = {
      source  = "DataDog/datadog"
      version = "4.13.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "datadog" {
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
  api_url  = "https://api.${var.datadog_site}/"
  validate = false
}
