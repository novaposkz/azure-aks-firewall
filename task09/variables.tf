# GENERAL
variable "location" {
  type        = string
  description = "The Azure region where all resources will be deployed"
}

# VNET
variable "vnet_space" {
  type        = string
  description = "The address space (CIDR block) for the virtual network"
}

# AKS
variable "subnet_name" {
  type        = string
  description = "The name of the subnet used for the AKS cluster."
}

variable "subnet_space" {
  type        = string
  description = "The address prefix (CIDR block) for the AKS subnet"
}

variable "aks_loadbalancer_ip" {
  type        = string
  description = "The public IP address of the AKS load balancer used for application traffic"
}