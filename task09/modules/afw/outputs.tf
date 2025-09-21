output "azure_firewall_public_ip" {
  description = "The public IP address assigned to the Azure Firewall for external access"
  value       = azurerm_public_ip.afw_pip.ip_address
}

output "azure_firewall_private_ip" {
  description = "The private IP address of the Azure Firewall used for internal routing"
  value       = azurerm_firewall.afw.ip_configuration[0].private_ip_address
}