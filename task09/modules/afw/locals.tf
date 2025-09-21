locals {
  afw_subnet_name   = "AzureFirewallSubnet"
  afw_subnet_prefix = cidrsubnet(var.vnet_space, 8, 1)

  afw_pip_name = "${var.unique_id}-pip"

  afw_name = "${var.unique_id}-afw"

  afw_route_table_name = "${var.unique_id}-rt"

  afw_app_rc     = "${var.unique_id}-app-rc"
  afw_network_rc = "${var.unique_id}-network-rc"
  afw_nat_rc     = "${var.unique_id}-nat-rc"

  application_rules = [
    {
      name             = "allow-app",
      source_addresses = ["*"],
      target_fqdns     = ["${var.aks_loadbalancer_ip}"]
      protocols = [
        { port = 80, type = "Http" },
        { port = 443, type = "Https" }
      ]
    }
  ]

  nsg_rule_name = "AllowAccessFromFirewallPublicIPToLoadBalancerIP"
  rg_name       = "MC_cmtr-f4p05tns-mod9-rg_cmtr-f4p05tns-mod9-aks_centralus"
  nsg_name      = "aks-agentpool-23946128-nsg"
}