locals {
  unique_id = "cmtr-f4p05tns-mod9"

  #RG
  rg_name = "${local.unique_id}-rg"

  #VNET
  vnet_name = "${local.unique_id}-vnet"

  #AKS
  AKS_CLUSTER_NAME = "${local.unique_id}-aks"
}