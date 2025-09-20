# main.tf
module "afw" {
  source = "./modules/afw"

  resource_group_name            = local.resource_group_name
  location                       = local.location
  vnet_name                      = local.vnet_name
  vnet_address_space             = local.vnet_address_space
  aks_subnet_name                = local.aks_subnet_name
  aks_subnet_address_prefix      = local.aks_subnet_address_prefix
  firewall_subnet_address_prefix = local.firewall_subnet_address_prefix
  aks_loadbalancer_ip            = var.aks_loadbalancer_ip
  tags                           = var.tags
}