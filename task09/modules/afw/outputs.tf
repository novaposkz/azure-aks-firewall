# ========================================================================
# AZURE FIREWALL MODULE OUTPUTS
# ========================================================================
# This file defines outputs from the Azure Firewall module that can be
# used by other modules or for external integration
# ========================================================================

# ========================================================================
# FIREWALL IP ADDRESS OUTPUTS
# ========================================================================

output "azure_firewall_public_ip" {
  description = "The public IP address assigned to the Azure Firewall for external access and NAT rules"
  value       = azurerm_public_ip.afw_pip.ip_address
  sensitive   = false
}

output "azure_firewall_private_ip" {
  description = "The private IP address of the Azure Firewall used for internal routing and network rules"
  value       = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  sensitive   = false
}

# ========================================================================
# FIREWALL RESOURCE OUTPUTS
# ========================================================================

output "firewall_resource_id" {
  description = "The full Azure resource ID of the deployed Azure Firewall"
  value       = azurerm_firewall.afw.id
}

output "firewall_name" {
  description = "The name of the deployed Azure Firewall resource"
  value       = azurerm_firewall.afw.name
}

output "firewall_subnet_id" {
  description = "The Azure resource ID of the AzureFirewallSubnet"
  value       = azurerm_subnet.afw_subnet.id
}

output "firewall_public_ip_id" {
  description = "The Azure resource ID of the firewall's public IP address"
  value       = azurerm_public_ip.afw_pip.id
}

# ========================================================================
# ROUTING CONFIGURATION OUTPUTS
# ========================================================================

output "route_table_id" {
  description = "The Azure resource ID of the route table associated with the AKS subnet"
  value       = azurerm_route_table.afw_rt.id
}

output "route_table_name" {
  description = "The name of the route table used for firewall traffic routing"
  value       = azurerm_route_table.afw_rt.name
}

# ========================================================================
# FIREWALL RULE COLLECTION OUTPUTS
# ========================================================================

output "application_rule_collection_name" {
  description = "The name of the firewall application rule collection"
  value       = azurerm_firewall_application_rule_collection.app_rules.name
}

output "network_rule_collection_name" {
  description = "The name of the firewall network rule collection"
  value       = azurerm_firewall_network_rule_collection.net_rules.name
}

output "nat_rule_collection_name" {
  description = "The name of the firewall NAT rule collection"
  value       = azurerm_firewall_nat_rule_collection.nat_rules.name
}

# ========================================================================
# NETWORK CONFIGURATION OUTPUTS
# ========================================================================

output "firewall_subnet_address_prefix" {
  description = "The address prefix of the Azure Firewall subnet"
  value       = local.afw_subnet_prefix
}

output "aks_subnet_association_id" {
  description = "The resource ID of the subnet route table association for the AKS subnet"
  value       = azurerm_subnet_route_table_association.associate_rt.id
}