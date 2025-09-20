# locals.tf
locals {
  resource_group_name            = "cmtr-f4p05tns-mod9-rg"
  location                       = "Central US"
  vnet_name                      = "cmtr-f4p05tns-mod9-vnet"
  vnet_address_space             = ["10.0.0.0/16"]
  aks_subnet_name                = "aks-snet"
  aks_subnet_address_prefix      = "10.0.0.0/24"
  firewall_subnet_address_prefix = "10.0.1.0/24"
}