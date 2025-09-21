# ========================================================================
# LOCAL VALUES CONFIGURATION
# ========================================================================
# This file defines local values used throughout the Terraform configuration
# for consistent resource naming and tagging strategies
# ========================================================================

locals {
  # ========================================================================
  # UNIQUE IDENTIFIER FOR RESOURCE NAMING
  # ========================================================================
  # This unique identifier ensures resource names are distinct across deployments
  # Format: project-environment-randomstring-module
  unique_id = "azure-sec-k8s-fw-${formatdate("YYYY-MM", timestamp())}-mod9"

  # ========================================================================
  # RESOURCE GROUP NAMING CONFIGURATION
  # ========================================================================
  rg_name = "${local.unique_id}-rg"

  # ========================================================================
  # VIRTUAL NETWORK NAMING CONFIGURATION
  # ========================================================================
  vnet_name = "${local.unique_id}-vnet"

  # ========================================================================
  # AZURE KUBERNETES SERVICE NAMING CONFIGURATION
  # ========================================================================
  AKS_CLUSTER_NAME = "${local.unique_id}-aks"

  # ========================================================================
  # COMMON TAGS FOR ALL RESOURCES
  # ========================================================================
  # These tags provide metadata for resource management and cost tracking
  common_tags = {
    Environment   = "production"
    Project       = "azure-firewall-security"
    Owner         = "devops-team"
    CostCenter    = "security-infrastructure"
    Deployment    = "terraform"
    Module        = "firewall-aks-integration"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    ManagedBy     = "terraform"
    Purpose       = "aks-firewall-security"
    Compliance    = "enterprise-security-standards"
  }

  # ========================================================================
  # NETWORK SECURITY CONFIGURATION
  # ========================================================================
  # Default security settings for the firewall deployment
  firewall_config = {
    sku_name                = "AZFW_VNet"
    sku_tier               = "Standard"
    threat_intel_mode      = "Alert"
    dns_servers            = []
    private_ip_ranges      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
}