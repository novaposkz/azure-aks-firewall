# ========================================================================
# TERRAFORM VARIABLES CONFIGURATION
# ========================================================================
# This file defines input variables for the Azure Firewall security
# infrastructure deployment with comprehensive validation rules
# ========================================================================

# ========================================================================
# GENERAL CONFIGURATION VARIABLES
# ========================================================================

variable "location" {
  type        = string
  description = "The Azure region where all security infrastructure resources will be deployed"
  
  validation {
    condition = can(regex("^[a-z]+[a-z0-9]*$", var.location))
    error_message = "Location must be a valid Azure region name in lowercase."
  }
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", 
      "northcentralus", "southcentralus", "westcentralus", "canadacentral", 
      "canadaeast", "brazilsouth", "northeurope", "westeurope", "uksouth", 
      "ukwest", "francecentral", "germanywestcentral", "norwayeast", 
      "switzerlandnorth", "swedencentral", "australiaeast", "australiasoutheast", 
      "southeastasia", "eastasia", "japaneast", "japanwest", "koreacentral", 
      "koreasouth", "southindia", "centralindia", "westindia"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

# ========================================================================
# VIRTUAL NETWORK CONFIGURATION VARIABLES
# ========================================================================

variable "vnet_space" {
  type        = string
  description = "The address space (CIDR block) for the virtual network hosting the firewall and AKS resources"
  
  validation {
    condition = can(cidrhost(var.vnet_space, 0))
    error_message = "Virtual network address space must be a valid CIDR block."
  }
  
  validation {
    condition = can(regex("^10\\.|^172\\.(1[6-9]|2[0-9]|3[01])\\.|^192\\.168\\.", var.vnet_space))
    error_message = "Virtual network must use private IP address space (10.0.0.0/8, 172.16.0.0/12, or 192.168.0.0/16)."
  }
}

# ========================================================================
# AZURE KUBERNETES SERVICE (AKS) CONFIGURATION VARIABLES
# ========================================================================

variable "subnet_name" {
  type        = string
  description = "The name of the subnet dedicated to the AKS cluster workloads"
  
  validation {
    condition = can(regex("^[a-zA-Z][a-zA-Z0-9-_]*[a-zA-Z0-9]$", var.subnet_name))
    error_message = "Subnet name must start with a letter, end with alphanumeric character, and contain only letters, numbers, hyphens, and underscores."
  }
  
  validation {
    condition = length(var.subnet_name) >= 3 && length(var.subnet_name) <= 63
    error_message = "Subnet name must be between 3 and 63 characters long."
  }
}

variable "subnet_space" {
  type        = string
  description = "The address prefix (CIDR block) for the AKS subnet within the virtual network"
  
  validation {
    condition = can(cidrhost(var.subnet_space, 0))
    error_message = "AKS subnet address space must be a valid CIDR block."
  }
}

variable "aks_loadbalancer_ip" {
  type        = string
  description = "The internal IP address of the AKS load balancer used for routing application traffic through the firewall"
  
  validation {
    condition = can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.aks_loadbalancer_ip))
    error_message = "AKS load balancer IP must be a valid IPv4 address."
  }
  
  validation {
    condition = can(regex("^10\\.|^172\\.(1[6-9]|2[0-9]|3[01])\\.|^192\\.168\\.", var.aks_loadbalancer_ip))
    error_message = "AKS load balancer IP must be within private IP address ranges."
  }
}