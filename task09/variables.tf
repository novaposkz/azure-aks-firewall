# variables.tf (исправленный - убрать defaults)
variable "aks_loadbalancer_ip" {
  description = "Public IP address of AKS load balancer"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}