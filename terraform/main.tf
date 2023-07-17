terraform {
  required_providers {
    ct = {
      source  = "poseidon/ct"
      version = "0.13.0"
    }

    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }

    template = {
      source  = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu+ssh://homestead/system"
}
