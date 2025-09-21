module "afw" {
  source              = "./modules/afw"
  location            = var.location
  rg_name             = local.rg_name
  vnet_name           = local.vnet_name
  vnet_space          = var.vnet_space
  subnet_name         = var.subnet_name
  aks_loadbalancer_ip = var.aks_loadbalancer_ip
  unique_id           = local.unique_id
}