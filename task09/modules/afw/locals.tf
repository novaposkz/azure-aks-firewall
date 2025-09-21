locals {
  firewall_subnet_name = "AzureFirewallSubnet"
  route_table_name     = "cmtr-f4p05tns-mod9-rt"
  firewall_name        = "cmtr-f4p05tns-mod9-afw"
  public_ip_name       = "cmtr-f4p05tns-mod9-pip"

  # Required FQDN tags for AKS - используем правильный регион
  aks_required_fqdns = [
    "*.hcp.centralus.azmk8s.io", # Изменено с "Central US" на "centralus"
    "mcr.microsoft.com",
    "*.data.mcr.microsoft.com",
    "management.azure.com",
    "login.microsoftonline.com",
    "packages.microsoft.com",
    "acs-mirror.azureedge.net",
    "*.azurecr.io",
    "*.blob.core.windows.net"
  ]

  # Динамические правила для network rules
  network_rules = [
    {
      name      = "allow-dns"
      ports     = ["53"]
      addresses = ["8.8.8.8", "8.8.4.4"]
      protocols = ["UDP", "TCP"]
    },
    {
      name      = "allow-ntp"
      ports     = ["123"]
      addresses = ["*"]
      protocols = ["UDP"]
    },
    {
      name        = format("%s-http-rule", var.project_prefix)
      ports       = ["80"]
      addresses   = ["*"]
      protocols   = ["TCP"]
    },
    {
      name        = format("%s-https-rule", var.project_prefix) 
      ports       = ["443"]
      addresses   = ["*"]
      protocols   = ["TCP"]
    }
  ]

  # Динамические правила для NAT
  nat_rules = [
    {
      name      = "nginx-http"
      port      = 80
      protocols = ["TCP"]
    },
    {
      name      = "nginx-https"
      port      = 443
      protocols = ["TCP"]
    }
  ]
  # Используем функции для преобразования региона
  location_normalized = replace(lower(var.location), " ", "")
  
  # FQDN с использованием функций
  aks_required_fqdns = [
    "*.hcp.${local.location_normalized}.azmk8s.io",
    "mcr.microsoft.com",
    "*.data.mcr.microsoft.com", 
    "management.azure.com",
    "login.microsoftonline.com",
    "packages.microsoft.com",
    "acs-mirror.azureedge.net",
    "*.azurecr.io",
    "*.blob.core.windows.net"
  ]

  # Имена с использованием format()
  app_rule_collection_name  = format("cmtr-%s-mod9-app-rc", var.project_prefix)
  net_rule_collection_name  = format("cmtr-%s-mod9-net-rc", var.project_prefix)
  nat_rule_collection_name  = format("cmtr-%s-mod9-nat-rc", var.project_prefix)
  route_name                = format("cmtr-%s-mod9-route", var.project_prefix)
}