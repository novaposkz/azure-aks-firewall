# modules/afw/locals.tf
locals {
  firewall_subnet_name = "AzureFirewallSubnet"
  route_table_name     = "cmtr-f4p05tns-mod9-rt"
  firewall_name        = "cmtr-f4p05tns-mod9-afw"
  public_ip_name       = "cmtr-f4p05tns-mod9-pip"

  # Required FQDN tags for AKS
  aks_required_fqdns = [
    "*.hcp.${var.location}.azmk8s.io",
    "mcr.microsoft.com",
    "*.data.mcr.microsoft.com",
    "management.azure.com",
    "login.microsoftonline.com",
    "packages.microsoft.com",
    "acs-mirror.azureedge.net",
    "*.azurecr.io",
    "*.blob.core.windows.net"
  ]
}