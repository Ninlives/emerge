terraform {
  backend "http" {
    address = "http://127.0.0.1:5000"
  }
  required_providers {
    vultr = {
      source = "vultr/vultr"
    }
    sops = {
      source = "carlpett/sops"
    }
    shell = {
      source = "scottwinkler/shell"
    }
    b2 = {
      source = "Backblaze/b2"
    }
  }
}
