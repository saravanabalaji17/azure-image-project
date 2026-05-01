packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 1.0.0"
    }
  }
}

variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
variable "subscription_id" {}

locals {
  #image_version = "1.0.${env("GITHUB_RUN_NUMBER")}"
  image_version = "1.0.0"
}

source "azure-arm" "ubuntu" {
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  location = "East US"
  vm_size  = "Standard_B2s"

  os_type         = "Linux"
  image_publisher = "canonical"
  image_offer     = "ubuntu-24_04-lts"
  image_sku       = "server"

  managed_image_resource_group_name = "packer-rg"
  managed_image_name                = "temp-image-${local.image_version}"

  shared_image_gallery_destination {
    subscription   = var.subscription_id
    resource_group = "1-7935f0a2-playground-sandbox"
    gallery_name   = "vsphere_gallery"
    image_name     = "balaji"
    image_version  = local.image_version
    replication_regions = ["East US"]
  }
}

build {
  sources = ["source.azure-arm.ubuntu"]

  # Required for Ansible
  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y python3"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./ansible/playbook.yml"
  }
}
