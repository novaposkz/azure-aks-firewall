resource "azurerm_subnet" "afw_subnet" {
  name                 = local.afw_subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.afw_subnet_prefix]
}

resource "azurerm_public_ip" "afw_pip" {
  name                = local.afw_pip_name
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_firewall" "afw" {
  name                = local.afw_name
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.afw_subnet.id
    public_ip_address_id = azurerm_public_ip.afw_pip.id
  }

  depends_on = [azurerm_subnet.afw_subnet, azurerm_public_ip.afw_pip]
}

resource "azurerm_route_table" "afw_rt" {
  name                = local.afw_route_table_name
  location            = var.location
  resource_group_name = var.rg_name

  route {
    name           = "route-to-firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet" # "VirtualAppliance"
    # next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_firewall.afw]
}

data "azurerm_subnet" "aks_snet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}


resource "azurerm_subnet_route_table_association" "associate_rt" {
  subnet_id      = data.azurerm_subnet.aks_snet.id
  route_table_id = azurerm_route_table.afw_rt.id

  depends_on = [data.azurerm_subnet.aks_snet, azurerm_route_table.afw_rt]
}

resource "azurerm_firewall_application_rule_collection" "app_rules" {
  name                = local.afw_app_rc
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 102
  action              = "Allow"

  dynamic "rule" {
    for_each = local.application_rules
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses
      target_fqdns     = rule.value.target_fqdns

      dynamic "protocol" {
        for_each = rule.value.protocols
        content {
          port = protocol.value.port
          type = protocol.value.type
        }
      }
    }
  }

  depends_on = [azurerm_firewall.afw]
}

resource "azurerm_firewall_network_rule_collection" "net_rules" {
  name                = local.afw_network_rc
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 101
  action              = "Allow"

  rule {
    name                  = "allow-network"
    source_addresses      = ["*"]
    destination_ports     = ["1-65535"]
    destination_addresses = ["*"]
    protocols             = ["UDP", "TCP"]
  }

  depends_on = [azurerm_firewall.afw]
}

resource "azurerm_firewall_nat_rule_collection" "nat_rules" {
  name                = local.afw_nat_rc
  resource_group_name = var.rg_name
  azure_firewall_name = azurerm_firewall.afw.name
  priority            = 100
  action              = "Dnat"

  rule {
    name                  = "nginx-dnat-http"
    destination_addresses = [azurerm_public_ip.afw_pip.ip_address]
    destination_ports     = ["80"]
    protocols             = ["TCP"]
    source_addresses      = ["*"]

    translated_port    = "80"
    translated_address = var.aks_loadbalancer_ip
  }

  depends_on = [azurerm_firewall.afw]
}


# resource "azurerm_network_security_rule" "allow_firewall_to_aks_lb" {
#   name                        = local.nsg_rule_name
#   priority                    = 101
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "80"
#   source_address_prefix       = azurerm_public_ip.afw_pip.ip_address
#   destination_address_prefix  = var.aks_loadbalancer_ip
#   resource_group_name         = local.rg_name
#   network_security_group_name = local.nsg_name

#   depends_on = [azurerm_firewall.afw]
# }