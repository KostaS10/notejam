resource "azurerm_frontdoor" "fd" {
  name                                         = "notejamappfd"
  location                                     = "global"
  resource_group_name                          = azurerm_resource_group.rg.name
  enforce_backend_pools_certificate_name_check = false

  routing_rule {
    name               = "exampleRoutingRule1"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["frontend"]
    forwarding_configuration {
      forwarding_protocol = "HttpOnly"
      backend_pool_name   = "apps"
    }
  }

  backend_pool_load_balancing {
    name = "exampleLoadBalancingSettings1"
  }

  backend_pool_health_probe {
    name = "exampleHealthProbeSetting1"
	protocol = "Http"
probe_method = "HEAD"
interval_in_seconds = "60"
  }

  backend_pool {
    name = "apps"
    backend {
      host_header = "notejamwe.westeurope.cloudapp.azure.com"
      address     = "notejamwe.westeurope.cloudapp.azure.com"
      http_port   = 80
      https_port  = 443
	priority = 1
    }
	backend {
      host_header = "notejamne.northeurope.cloudapp.azure.com"
      address     = "notejamne.northeurope.cloudapp.azure.com"
      http_port   = 80
      https_port  = 443
	priority = 2
    }

    load_balancing_name = "exampleLoadBalancingSettings1"
    health_probe_name   = "exampleHealthProbeSetting1"
  }

  frontend_endpoint {
    name                              = "frontend"
    host_name                         = "notejamappfd.azurefd.net"
    session_affinity_enabled = true
    custom_https_provisioning_enabled = false
  }
}
