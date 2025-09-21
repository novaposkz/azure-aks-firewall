# ========================================================================
# AZURE FIREWALL MODULE VARIABLES
# ========================================================================
# This file defines input variables for the Azure Firewall module
# with comprehensive type definitions and validation rules
# ========================================================================

# ========================================================================
# GENERAL CONFIGURATION VARIABLES
# ========================================================================

variable "unique_id" {
  type        = string
  description = "Unique identifier used for consistent resource naming across the deployment"
  
  validation {
    condition     = length(var.unique_id) >= 5 && length(var.unique_id) <= 50
    error_message = "Unique ID must be between 5 and 50 characters long."
  }
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.unique_id))
    error_message = "Unique ID must contain only alphanumeric characters and hyphens."
  }
}

variable "location" {
  type        = string
  description = "Azure region where the firewall and associated resources will be deployed"
  
  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", 
      "northcentralus", "southcentralus", "westcentralus"
    ], var.location)
    error_message = "Location must be a valid Azure region."
  }
}

variable "rg_name" {
  type        = string
  description = "Name of the existing resource group where firewall resources will be created"
  
  validation {
    condition     = length(var.rg_name) >= 1 && length(var.rg_name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

# ========================================================================
# VIRTUAL NETWORK CONFIGURATION VARIABLES
# ========================================================================

variable "vnet_name" {
  type        = string
  description = "Name of the existing virtual network where the firewall subnet will be created"
  
  validation {
    condition     = length(var.vnet_name) >= 2 && length(var.vnet_name) <= 64
    error_message = "Virtual network name must be between 2 and 64 characters."
  }
}

variable "vnet_space" {
  type        = string
  description = "Address space of the virtual network used for subnet calculations"
  
  validation {
    condition     = can(cidrhost(var.vnet_space, 0))
    error_message = "Virtual network space must be a valid CIDR block."
  }
}

# ========================================================================
# AZURE KUBERNETES SERVICE CONFIGURATION VARIABLES
# ========================================================================

variable "subnet_name" {
  type        = string
  description = "Name of the AKS subnet that will be associated with the firewall route table"
  
  validation {
    condition     = length(var.subnet_name) >= 2 && length(var.subnet_name) <= 80
    error_message = "Subnet name must be between 2 and 80 characters."
  }
}

variable "aks_loadbalancer_ip" {
  type        = string
  description = "Internal IP address of the AKS load balancer for NAT rule configuration"
  
  validation {
    condition = can(regex("^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.aks_loadbalancer_ip))
    error_message = "AKS load balancer IP must be a valid IPv4 address."
  }
}

# ========================================================================
# OPTIONAL CONFIGURATION VARIABLES
# ========================================================================

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to all firewall-related resources"
  default     = {}
  
  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags can be applied to resources."
  }
}