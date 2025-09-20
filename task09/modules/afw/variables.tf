# modules/afw/variables.tf
variable "resource_group_name" {
  description = "Name of the existing resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the existing virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the existing virtual network"
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "Name of the existing AKS subnet"
  type        = string
}

variable "aks_subnet_address_prefix" {
  description = "Address prefix of the existing AKS subnet"
  type        = string
}

variable "firewall_subnet_address_prefix" {
  description = "Address prefix for Azure Firewall subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aks_loadbalancer_ip" {
  description = "Public IP address of AKS load balancer"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}