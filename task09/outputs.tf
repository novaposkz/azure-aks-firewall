# ========================================================================
# TERRAFORM OUTPUTS CONFIGURATION
# ========================================================================
# This file defines outputs that provide important information about
# the deployed Azure Firewall security infrastructure
# ========================================================================

# ========================================================================
# AZURE FIREWALL IP ADDRESS OUTPUTS
# ========================================================================

output "azure_firewall_public_ip" {
  description = "The public IP address assigned to the Azure Firewall for external access and NAT rules"
  value       = module.azure_firewall_security.azure_firewall_public_ip
  sensitive   = false
}

output "azure_firewall_private_ip" {
  description = "The private IP address of the Azure Firewall used for internal routing and network rules"
  value       = module.azure_firewall_security.azure_firewall_private_ip
  sensitive   = false
}

# ========================================================================
# RESOURCE IDENTIFICATION OUTPUTS
# ========================================================================

output "firewall_resource_id" {
  description = "The full Azure resource ID of the deployed firewall for integration with other services"
  value       = module.azure_firewall_security.firewall_resource_id
}

output "firewall_subnet_id" {
  description = "The Azure resource ID of the AzureFirewallSubnet used by the firewall"
  value       = module.azure_firewall_security.firewall_subnet_id
}

output "route_table_id" {
  description = "The Azure resource ID of the route table associated with the AKS subnet"
  value       = module.azure_firewall_security.route_table_id
}

# ========================================================================
# DEPLOYMENT INFORMATION OUTPUTS
# ========================================================================

output "deployment_region" {
  description = "The Azure region where the firewall infrastructure was deployed"
  value       = var.location
}

output "resource_group_name" {
  description = "The name of the resource group containing the firewall resources"
  value       = local.rg_name
}

output "unique_deployment_id" {
  description = "The unique identifier used for this deployment to ensure resource name uniqueness"
  value       = local.unique_id
}

# ========================================================================
# NETWORK CONFIGURATION OUTPUTS
# ========================================================================

output "virtual_network_name" {
  description = "The name of the virtual network hosting the firewall and AKS resources"
  value       = local.vnet_name
}

output "aks_loadbalancer_ip" {
  description = "The AKS load balancer IP address configured for firewall NAT rules"
  value       = var.aks_loadbalancer_ip
  sensitive   = false
}