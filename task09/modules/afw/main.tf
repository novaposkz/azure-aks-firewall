# Create subnet for Azure Firewall
resource "azurerm_subnet" "firewall" {
  name                 = local.firewall_subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.firewall_subnet_address_prefix]
}

# Create Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall" {
  name                = local.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Create Azure Firewall
resource "azurerm_firewall" "main" {
  name                = local.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# Create Route Table
resource "azurerm_route_table" "main" {
  name                = local.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create route to force traffic through Azure Firewall
resource "azurerm_route" "firewall" {
  name                   = "ToAzureFirewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.main.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
}

# Associate route table with AKS subnet
resource "azurerm_subnet_route_table_association" "aks" {
  subnet_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.vnet_name}/subnets/${var.aks_subnet_name}"
  route_table_id = azurerm_route_table.main.id
}

# Application Rule Collection for AKS required FQDNs
resource "azurerm_firewall_application_rule_collection" "aks_required" {
  name                = "aks-required-fqdns"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name = "allow-aks-required-fqdns"

    source_addresses = [
      var.aks_subnet_address_prefix
    ]

    target_fqdns = local.aks_required_fqdns

    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

# Network Rule Collection for outbound traffic with dynamic blocks
resource "azurerm_firewall_network_rule_collection" "outbound" {
  name                = "outbound-network-rules"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  dynamic "rule" {
    for_each = local.network_rules

    content {
      name = rule.value.name

      source_addresses = [
        var.aks_subnet_address_prefix
      ]

      destination_ports = rule.value.ports

      destination_addresses = rule.value.addresses

      protocols = rule.value.protocols
    }
  }
}

# NAT Rule Collection for inbound traffic to NGINX with dynamic blocks
resource "azurerm_firewall_nat_rule_collection" "nginx" {
  name                = "nginx-inbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 300
  action              = "Dnat"

  dynamic "rule" {
    for_each = local.nat_rules

    content {
      name = rule.value.name

      source_addresses = ["*"]

      destination_ports = [tostring(rule.value.port)]

      destination_addresses = [
        azurerm_public_ip.firewall.ip_address
      ]

      translated_port    = rule.value.port
      translated_address = var.aks_loadbalancer_ip

      protocols = rule.value.protocols
    }
  }
}

# Data source for current subscription
data "azurerm_subscription" "current" {}