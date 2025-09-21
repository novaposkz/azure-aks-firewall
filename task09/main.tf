# ========================================================================
# AZURE FIREWALL SECURITY MODULE DEPLOYMENT
# ========================================================================
# This configuration deploys an Azure Firewall with comprehensive
# security rules and routing configuration for AKS cluster protection
# ========================================================================

module "azure_firewall_security" {
  source = "./modules/afw"

  # Location and resource naming configuration
  location  = var.location
  rg_name   = local.rg_name
  unique_id = local.unique_id

  # Virtual network configuration for firewall deployment
  vnet_name  = local.vnet_name
  vnet_space = var.vnet_space

  # AKS cluster integration settings
  subnet_name         = var.subnet_name
  aks_loadbalancer_ip = var.aks_loadbalancer_ip

  # Additional tags for resource management
  tags = local.common_tags
}