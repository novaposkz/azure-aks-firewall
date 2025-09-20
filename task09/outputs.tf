# outputs.tf
output "azure_firewall_public_ip" {
  description = "Public IP address of Azure Firewall"
  value       = module.afw.firewall_public_ip
}

output "azure_firewall_private_ip" {
  description = "Private IP address of Azure Firewall"
  value       = module.afw.firewall_private_ip
}