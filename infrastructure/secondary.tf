resource "azurerm_resource_group" "rg2" {
  name     = var.rg2
  location = var.location2
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vmnetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
}

resource "azurerm_subnet" "snet2" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip2" {
  name                = "vmpip2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  allocation_method   = "Static"

}

resource "azurerm_network_security_group" "nsg2" {
  name                = "nsg2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  security_rule {
    name                       = "inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip2.id
  }
}

resource "azurerm_subnet_network_security_group_association" "snetnsg2" {
  subnet_id                 = azurerm_subnet.snet2.id
  network_security_group_id = azurerm_network_security_group.nsg2.id
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss2" {
  name                            = "notejamvmss2"
  resource_group_name             = azurerm_resource_group.rg2.name
  location                        = azurerm_resource_group.rg2.location
  sku                             = "Standard_B1ms"
  instances                       = 1
  admin_username                  = "nordcloud"
  admin_password                  = var.adminpass
  disable_password_authentication = false
  upgrade_mode = "Automatic"

source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

network_interface {
    name    = "nic2"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.snet2.id
 load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool2.id]
    }
  }

lifecycle {
    ignore_changes = ["instances"]
  }
}

resource "azurerm_virtual_machine_scale_set_extension" "script2" {
  name                 = "server"
  virtual_machine_scale_set_id = azurerm_linux_virtual_machine_scale_set.vmss2.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
  "fileUris": ["https://raw.githubusercontent.com/KostaS10/notejam/master/configureServerbackup.sh"],
  "commandToExecute": "sh configureServerbackup.sh"
    }
SETTINGS
}

resource "azurerm_monitor_autoscale_setting" "lbautoscale2" {
  name                = "lbautoscale2"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss2.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
        metric_namespace   = "microsoft.compute/virtualmachinescalesets"

      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss2.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
    }
  }
}

resource "azurerm_public_ip" "lbpip2" {
  name                = "PublicIPForLB2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Static"
 domain_name_label = "notejamne"
}

resource "azurerm_lb" "lb2" {
  name                = "LoadBalancer2"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lbpip2.id
  }
}

resource "azurerm_lb_rule" "lbnatrule2" {
   resource_group_name            = azurerm_resource_group.rg2.name
   loadbalancer_id                = azurerm_lb.lb2.id
   name                           = "http"
   protocol                       = "Tcp"
   frontend_port                  = "80"
   backend_port                   = "80"
   backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool2.id
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = azurerm_lb_probe.vmss2.id
}

resource "azurerm_lb_probe" "vmss2" {
 resource_group_name = azurerm_resource_group.rg2.name
 loadbalancer_id     = azurerm_lb.lb2.id
 name                = "http-running-probe"
 port                = "80"
}

resource "azurerm_lb_backend_address_pool" "bpepool2" {
 resource_group_name = azurerm_resource_group.rg2.name
 loadbalancer_id     = azurerm_lb.lb2.id
 name                = "BackEndAddressPool"
}
