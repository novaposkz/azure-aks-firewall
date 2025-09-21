# ========================================================================
# AZURE FIREWALL SUBNET CONFIGURATION
# ========================================================================
# Creates a dedicated subnet for Azure Firewall with the required name
# "AzureFirewallSubnet" and appropriate address space
# ========================================================================

resource "azurerm_subnet" "afw_subnet" {
  name                 = local.afw_subnet_name
  resource_group_name  = var.rg_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [local.afw_subnet_prefix]

  # Apply tags to the subnet for resource management
  # Note: Subnets inherit tags from the parent virtual network
  
  # Lifecycle management to prevent accidental deletion
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# ========================================================================
# AZURE FIREWALL PUBLIC IP CONFIGURATION
# ========================================================================
# Creates a static public IP address for the Azure Firewall with Standard SKU
# required for firewall deployment and external connectivity
# ========================================================================

resource "azurerm_public_ip" "afw_pip" {
  name                = local.afw_pip_name
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "Zone-Redundant"  # Enhanced availability
  
  # Apply merged tags for consistent resource management
  tags = local.merged_tags

  # Lifecycle management for safe resource updates
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
  }
}

# ========================================================================
# AZURE FIREWALL MAIN RESOURCE
# ========================================================================
# Deploys the Azure Firewall with Standard tier for comprehensive
# network security and traffic filtering capabilities
# ========================================================================

# ========================================================================
# AZURE FIREWALL POLICY CONFIGURATION
# ========================================================================
# Creates a firewall policy for centralized rule management and
# enhanced security features with threat intelligence
# ========================================================================

resource "azurerm_firewall_policy" "afw_policy" {
  name                = "${local.afw_name}-policy"
  resource_group_name = var.rg_name
  location            = var.location
  sku                 = local.firewall_config.sku_tier
  
  # Enable threat intelligence for advanced security
  threat_intelligence_mode = "Alert"
  
  # DNS configuration for proper name resolution
  dns {
    proxy_enabled = true
    servers       = local.firewall_config.dns_servers
  }
  
  # Intrusion detection and prevention system settings
  intrusion_detection {
    mode = "Alert"
  }
  
  # Apply merged tags for consistent resource management
  tags = local.merged_tags
}

resource "azurerm_firewall" "afw" {
  name                = local.afw_name
  location            = var.location
  resource_group_name = var.rg_name
  sku_name            = local.firewall_config.sku_name
  sku_tier            = local.firewall_config.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.afw_policy.id
  
  # Primary IP configuration for firewall connectivity
  ip_configuration {
    name                 = "primary-ip-config"
    subnet_id            = azurerm_subnet.afw_subnet.id
    public_ip_address_id = azurerm_public_ip.afw_pip.id
  }

  # Apply merged tags for consistent resource management
  tags = local.merged_tags

  # Explicit dependency management for proper resource ordering
  depends_on = [
    azurerm_subnet.afw_subnet,
    azurerm_public_ip.afw_pip,
    azurerm_firewall_policy.afw_policy
  ]

  # Lifecycle management to prevent accidental deletion
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
  }
}

# ========================================================================
# AZURE ROUTE TABLE CONFIGURATION
# ========================================================================
# Creates a route table to direct traffic through the Azure Firewall
# for comprehensive network traffic inspection and control
# ========================================================================

resource "azurerm_route_table" "afw_rt" {
  name                          = local.afw_route_table_name
  location                      = var.location
  resource_group_name           = var.rg_name
  disable_bgp_route_propagation = false

  # Default route to direct all traffic through the firewall
  route {
    name                   = "default-route-via-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.afw.ip_configuration[0].private_ip_address
  }

  # Additional route for Azure services (optional)
  route {
    name           = "azure-services-route"
    address_prefix = "168.63.129.16/32"
    next_hop_type  = "Internet"
  }

  # Apply merged tags for consistent resource management
  tags = local.merged_tags

  # Explicit dependency on firewall deployment
  depends_on = [azurerm_firewall.afw]

  # Lifecycle management for safe updates
  lifecycle {
    create_before_destroy = true
  }
}

# ========================================================================
# AKS SUBNET DATA SOURCE AND ROUTE TABLE ASSOCIATION
# ========================================================================
# Retrieves the existing AKS subnet and associates it with the firewall
# route table to ensure all AKS traffic is routed through the firewall
# ========================================================================

data "azurerm_subnet" "aks_snet" {
  name                 = var.subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}

resource "azurerm_subnet_route_table_association" "associate_rt" {
  subnet_id      = data.azurerm_subnet.aks_snet.id
  route_table_id = azurerm_route_table.afw_rt.id

  # Explicit dependency management for proper resource ordering
  depends_on = [
    data.azurerm_subnet.aks_snet,
    azurerm_route_table.afw_rt
  ]

  # Lifecycle management to handle updates gracefully
  lifecycle {
    create_before_destroy = true
  }
}

# ========================================================================
# AZURE FIREWALL APPLICATION RULES COLLECTION
# ========================================================================
# Defines application layer (Layer 7) rules for HTTP/HTTPS traffic
# filtering based on FQDNs and protocols
# ========================================================================

resource "azurerm_firewall_application_rule_collection" "app_rules" {
  name                = local.afw_app_rc
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 200  # Higher priority for application rules
  action              = "Allow"

  # Dynamic rule creation from local configuration
  dynamic "rule" {
    for_each = local.application_rules
    content {
      name             = rule.value.name
      source_addresses = rule.value.source_addresses
      target_fqdns     = rule.value.target_fqdns

      # Dynamic protocol configuration for HTTP/HTTPS
      dynamic "protocol" {
        for_each = rule.value.protocols
        content {
          port = protocol.value.port
          type = protocol.value.type
        }
      }
    }
  }

  # Explicit dependency on firewall deployment
  depends_on = [azurerm_firewall.afw]

  # Lifecycle management for rule updates
  lifecycle {
    create_before_destroy = false
  }
}

# ========================================================================
# AZURE FIREWALL NETWORK RULES COLLECTION
# ========================================================================
# Defines network layer (Layer 3/4) rules for protocol-based traffic
# filtering including DNS, NTP, and Kubernetes API access
# ========================================================================

resource "azurerm_firewall_network_rule_collection" "net_rules" {
  name                = local.afw_network_rc
  azure_firewall_name = azurerm_firewall.afw.name
  resource_group_name = var.rg_name
  priority            = 150  # Medium priority for network rules
  action              = "Allow"

  # Dynamic rule creation from local configuration
  dynamic "rule" {
    for_each = local.network_rules
    content {
      name                  = rule.value.name
      source_addresses      = rule.value.source_addresses
      destination_addresses = rule.value.destination_addresses
      destination_ports     = rule.value.destination_ports
      protocols             = rule.value.protocols
    }
  }

  # Explicit dependency on firewall deployment
  depends_on = [azurerm_firewall.afw]

  # Lifecycle management for rule updates
  lifecycle {
    create_before_destroy = false
  }
}

# ========================================================================
# AZURE FIREWALL NAT RULES COLLECTION
# ========================================================================
# Defines destination NAT (DNAT) rules to forward external traffic
# to internal AKS load balancer for application access
# ========================================================================

resource "azurerm_firewall_nat_rule_collection" "nat_rules" {
  name                = local.afw_nat_rc
  resource_group_name = var.rg_name
  azure_firewall_name = azurerm_firewall.afw.name
  priority            = 100  # Highest priority for NAT rules
  action              = "Dnat"

  # HTTP traffic forwarding rule
  rule {
    name                  = "aks-http-dnat"
    destination_addresses = [azurerm_public_ip.afw_pip.ip_address]
    destination_ports     = ["80"]
    protocols             = ["TCP"]
    source_addresses      = ["*"]
    translated_port       = "80"
    translated_address    = var.aks_loadbalancer_ip
  }

  # HTTPS traffic forwarding rule
  rule {
    name                  = "aks-https-dnat"
    destination_addresses = [azurerm_public_ip.afw_pip.ip_address]
    destination_ports     = ["443"]
    protocols             = ["TCP"]
    source_addresses      = ["*"]
    translated_port       = "443"
    translated_address    = var.aks_loadbalancer_ip
  }

  # Explicit dependency on firewall deployment
  depends_on = [azurerm_firewall.afw]

  # Lifecycle management for rule updates
  lifecycle {
    create_before_destroy = false
  }
}