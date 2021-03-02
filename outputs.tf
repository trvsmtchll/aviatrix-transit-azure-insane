output "transit_vnet" {
  value = module.azure_transit_1.azure_vnet_name
}

output "transit_gateway" {
  value = module.azure_transit_1.transit_gateway.gw_name
}

output "vng_subnet" {
  value = azurerm_subnet.vng_gateway_subnet.name
}

output "spoke" {
  value = module.azure_spoke
}

output "test_vm" {
  value = module.azure_test_vm
}

output "test_vm_password" {
  value = random_password.password.result
}
