# modules/afw/outputs.tf
output "firewall_public_ip" {
  description = "Public IP address of Azure Firewall"
  value       = azurerm_public_ip.firewall.ip_address
}

output "firewall_private_ip" {
  description = "Private IP address of Azure Firewall"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

output "firewall_id" {
  description = "ID of Azure Firewall"
  value       = azurerm_firewall.main.id
}