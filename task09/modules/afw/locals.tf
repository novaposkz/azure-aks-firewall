# ========================================================================
# AZURE FIREWALL MODULE LOCAL VALUES
# ========================================================================
# This file defines local values used within the Azure Firewall module
# for consistent resource naming and configuration management
# ========================================================================

locals {
  # ========================================================================
  # FIREWALL SUBNET CONFIGURATION
  # ========================================================================
  # Azure Firewall requires a dedicated subnet named "AzureFirewallSubnet"
  afw_subnet_name   = "AzureFirewallSubnet"
  afw_subnet_prefix = cidrsubnet(var.vnet_space, 8, 2)  # Changed from 1 to 2 for uniqueness

  # ========================================================================
  # FIREWALL RESOURCE NAMING
  # ========================================================================
  afw_pip_name         = "${var.unique_id}-firewall-pip"
  afw_name             = "${var.unique_id}-security-firewall"
  afw_route_table_name = "${var.unique_id}-firewall-rt"

  # ========================================================================
  # FIREWALL RULE COLLECTION NAMING
  # ========================================================================
  afw_app_rc     = "${var.unique_id}-application-rules"
  afw_network_rc = "${var.unique_id}-network-rules"
  afw_nat_rc     = "${var.unique_id}-nat-rules"

  # ========================================================================
  # FIREWALL APPLICATION RULES CONFIGURATION
  # ========================================================================
  # Define application layer rules for web traffic filtering
  application_rules = [
    {
      name             = "allow-web-traffic"
      source_addresses = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
      target_fqdns = [
        "*.microsoft.com",
        "*.windows.net",
        "*.azure.com",
        "*.ubuntu.com",
        "*.docker.io",
        "registry-1.docker.io",
        "production.cloudflare.docker.com",
        "*.githubusercontent.com",
        "github.com",
        "*.k8s.io",
        "kubernetes.io"
      ]
      protocols = [
        { port = "80", type = "Http" },
        { port = "443", type = "Https" }
      ]
    },
    {
      name             = "allow-aks-services"
      source_addresses = ["*"]
      target_fqdns = [
        "*.hcp.${var.location}.azmk8s.io",
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        "management.azure.com",
        "login.microsoftonline.com",
        "packages.microsoft.com",
        "acs-mirror.azureedge.net"
      ]
      protocols = [
        { port = "80", type = "Http" },
        { port = "443", type = "Https" }
      ]
    }
  ]

  # ========================================================================
  # NETWORK SECURITY GROUP CONFIGURATION
  # ========================================================================
  # Configuration for network security rules (currently commented out in main.tf)
  nsg_rule_name = "AllowFirewallToAKSLoadBalancer"
  
  # ========================================================================
  # MERGED TAGS CONFIGURATION
  # ========================================================================
  # Combine input tags with module-specific tags
  merged_tags = merge(var.tags, {
    Module      = "azure-firewall-security"
    Component   = "network-security"
    Terraform   = "true"
    Environment = "production"
  })

  # ========================================================================
  # FIREWALL NETWORK RULES CONFIGURATION
  # ========================================================================
  # Define network layer rules for protocol-level filtering
  network_rules = [
    {
      name                  = "allow-dns"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols            = ["UDP", "TCP"]
    },
    {
      name                  = "allow-ntp"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["123"]
      protocols            = ["UDP"]
    },
    {
      name                  = "allow-kubernetes-api"
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["*"]
      destination_ports     = ["443", "6443"]
      protocols            = ["TCP"]
    }
  ]

  # ========================================================================
  # FIREWALL NAT RULES CONFIGURATION
  # ========================================================================
  # Define destination NAT rules for traffic forwarding
  nat_rules = [
    {
      name                  = "aks-http-dnat"
      destination_addresses = []  # Will be populated with firewall public IP
      destination_ports     = ["80"]
      protocols            = ["TCP"]
      source_addresses     = ["*"]
      translated_port      = "80"
      translated_address   = var.aks_loadbalancer_ip
    },
    {
      name                  = "aks-https-dnat"
      destination_addresses = []  # Will be populated with firewall public IP
      destination_ports     = ["443"]
      protocols            = ["TCP"]
      source_addresses     = ["*"]
      translated_port      = "443"
      translated_address   = var.aks_loadbalancer_ip
    }
  ]
}