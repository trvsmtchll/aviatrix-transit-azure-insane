# Azure Transit Module
module "azure_transit_1" {
  source                 = "terraform-aviatrix-modules/azure-transit/aviatrix"
  version                = "3.0.0"
  instance_size          = var.instance_size
  ha_gw                  = var.ha_enabled
  cidr                   = var.azure_transit_cidr1
  region                 = var.azure_region1
  account                = var.azure_account_name
  enable_transit_firenet = true
  insane_mode            = true
}

# Express Route VNG GatewaySubnet in Aviatrix Transit VNET
resource "azurerm_subnet" "vng_gateway_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = module.azure_transit_1.vnet.resource_group
  virtual_network_name = module.azure_transit_1.vnet.name
  address_prefixes     = [var.azure_vng_subnet_cidr]
}

# Azure Spokes
module "azure_spoke" {
  for_each      = var.spokes
  source        = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  version       = "3.0.0"
  name          = each.key
  cidr          = each.value
  region        = var.azure_region1
  account       = var.azure_account_name
  insane_mode   = true
  instance_size = var.instance_size
  transit_gw    = module.azure_transit_1.transit_gateway.gw_name
}

# Aviatrix Test VM Resource Group
resource "azurerm_resource_group" "example" {
  name     = "aviatrix-poc-rg"
  location = var.azure_region1
}

# Test VMs
module "azure_test_vm" {
  for_each                      = var.spokes
  source                        = "Azure/compute/azurerm"
  resource_group_name           = azurerm_resource_group.example.name
  vm_hostname                   = "${each.key}-avx-test-vm"
  nb_public_ip                  = 1
  remote_port                   = "22"
  vm_os_simple                  = "UbuntuServer"
  vnet_subnet_id                = module.azure_spoke[each.key].vnet.public_subnets[1].subnet_id
  delete_os_disk_on_termination = true
  custom_data                   = data.template_file.azure-init.rendered
  admin_password                = random_password.password.result
  enable_ssh_key                = false
  vm_size                       = var.test_instance_size
  tags = {
    environment = "aviatrix-poc"
    name        = "${each.key}-avx-test-vm"
  }
  depends_on = [azurerm_resource_group.example]
}

data "template_file" "azure-init" {
  template = file("${path.module}/azure-vm-config/azure_bootstrap.sh")
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

/*
#ssh
resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > ./priv-key.pem"
  }

  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.public_key_openssh}\" > ./id_rsa.pub"
  }

  provisioner "local-exec" {
    command = "chmod 600 ./priv-key.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 ./id_rsa.pub"
  }
}*/

