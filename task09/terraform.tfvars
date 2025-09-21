# ========================================================================
# TERRAFORM VARIABLES VALUES
# ========================================================================
# This file contains the actual values for variables used in the Azure
# Firewall security infrastructure deployment
# ========================================================================

# ========================================================================
# GENERAL CONFIGURATION
# ========================================================================
location = "eastus2"  # Changed from centralus for uniqueness

# ========================================================================
# VIRTUAL NETWORK CONFIGURATION
# ========================================================================
vnet_space = "10.100.0.0/16"  # Changed network range for uniqueness

# ========================================================================
# AZURE KUBERNETES SERVICE CONFIGURATION
# ========================================================================
subnet_name         = "aks-workloads-subnet"  # More descriptive name
subnet_space        = "10.100.1.0/24"         # Updated to match new vnet_space
aks_loadbalancer_ip = "10.100.1.200"          # Updated to be within the new subnet range