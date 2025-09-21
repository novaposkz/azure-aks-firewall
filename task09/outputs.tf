output "azure_firewall_public_ip" {
  description = "The public IP address assigned to the Azure Firewall for external access"
  value       = module.afw.azure_firewall_public_ip
}

output "azure_firewall_private_ip" {
  description = "The private IP address of the Azure Firewall used for internal routing"
  value       = module.afw.azure_firewall_private_ip
}