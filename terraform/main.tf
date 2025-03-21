provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

#-------------------------------------- Terraform to provision App Service & ACR ----------------------------
# 🔹 Resource Group (Existing or New)
resource "azurerm_resource_group" "my_rg" {
  name     = var.resource_group_name
  location = var.location
}

# 🔹 Azure Container Registry (ACR)
resource "azurerm_container_registry" "my_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }
}


# 🔹 App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = var.app_service_plan_name
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  os_type             = "Linux"
  sku_name            = "B1"
}

# 🔹 App Service with Container Deployment
resource "azurerm_linux_web_app" "web_app" {
  name                = var.app_service_name
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id 

 identity {
    type = "SystemAssigned"  # ⬅️ تمكين Managed Identity
  }


 site_config {
    always_on        = true  
    linux_fx_version = "DOCKER|${azurerm_container_registry.my_acr.login_server}/my-app:latest"
  }

  app_settings = {
    "WEBSOCKET_ENABLED" = "true"
  }
}

 


#------------------------------------------------ azure montor / alerts ---------------------------
# 🔹 Application Insights for Monitoring
resource "azurerm_application_insights" "app_insights" {
  name                = "myAppInsights"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  application_type    = "web"
}



# 🔹 Latency Alert (If response time > 2s)
resource "azurerm_monitor_metric_alert" "latency_alert" {
  name                = "latency-alert"
  resource_group_name = azurerm_resource_group.my_rg.name
  scopes             = [azurerm_linux_web_app.web_app.id]
  description        = "Alert if latency is greater than 2 seconds"
  severity           = 2

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "AverageResponseTime"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 2000  # 2 seconds
  }
}


# 🔹 WebSocket Failures Alert
resource "azurerm_monitor_metric_alert" "websocket_failure_alert" {
  name                = "websocket-failure-alert"
  resource_group_name = azurerm_resource_group.my_rg.name
  scopes             = [azurerm_linux_web_app.web_app.id]
  description        = "Alert on WebSocket failure spikes"
  severity           = 3

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "WebSocketRequestsFailed"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5  # Alert if more than 5 WebSocket failures occur
  }
}

# 🔹 Downtime Alert
resource "azurerm_monitor_metric_alert" "downtime_alert" {
  name                = "downtime-alert"
  resource_group_name = azurerm_resource_group.my_rg.name
  scopes             = [azurerm_linux_web_app.web_app.id]
  description        = "Alert when the app is down"
  severity           = 1

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }
}

#----------------------------------------auto restart/auto scaling ---------------------------------

# 🔹 Auto-Scaling Based on Active Connections
resource "azurerm_monitor_autoscale_setting" "autoscale" {
  name                = "autoscale-app-service"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  target_resource_id  = azurerm_service_plan.app_service_plan.id

  profile {
    name = "default"

    capacity {
      default = 1
      minimum = 1
      maximum = 3  # Maximum 3 instances for scaling
    }

    rule {
      metric_trigger {
        metric_name        = "ActiveConnections"
        metric_namespace   = "Microsoft.Web/sites"
        time_grain         = "PT1M"
        time_window        = "PT5M"  # Required field
        statistic          = "Count"  # More accurate for connection tracking
        operator           = "GreaterThan"
        threshold          = 100  # Scale when more than 100 active connections
        time_aggregation   = "Average"
        metric_resource_id = azurerm_linux_web_app.web_app.id
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT2M"  # Wait 2 minutes before next scaling action
      }
    }

    rule {
      metric_trigger {
        metric_name        = "ActiveConnections"
        metric_namespace   = "Microsoft.Web/sites"
        time_grain         = "PT1M"
        time_window        = "PT5M"  # Required field
        statistic          = "Count"  # More accurate for connection tracking
        operator           = "LessThan"
        threshold          = 50  # Scale down when connections drop below 50
        time_aggregation   = "Average"
        metric_resource_id = azurerm_linux_web_app.web_app.id
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = 1
        cooldown  = "PT5M"  # Wait 5 minutes before scaling down
      }
    }
  }
}


#---------------------------------------------------  NSGs to secure -------------------------------
resource "azurerm_virtual_network" "my_vnet" {
  name                = "my-vnet"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private_link_subnet" {
  name                 = "private-link-subnet"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.my_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_private_endpoint" "app_service_pe" {
  name                = "app-service-private-endpoint"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  subnet_id           = azurerm_subnet.private_link_subnet.id

  private_service_connection {
    name                           = "appservice-private-connection"
    private_connection_resource_id = azurerm_linux_web_app.web_app.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

resource "azurerm_network_security_group" "websocket_nsg" {
  name                = "websocket-nsg"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
}

# 🔹 السماح بالاتصال عبر WebSocket فقط من Subnet معينة
resource "azurerm_network_security_rule" "allow_websocket_traffic" {
  name                        = "AllowWebSocketTraffic"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_address_prefix       = "10.0.2.0/24"  # ضع Subnet الصحيحة الخاصة بالـ Private Endpoint
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  resource_group_name         = azurerm_resource_group.my_rg.name
  network_security_group_name = azurerm_network_security_group.websocket_nsg.name
}

# 🔹 رفض أي اتصال غير مصرح به
resource "azurerm_network_security_rule" "deny_all" {
  name                        = "DenyAllInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_address_prefix       = "*"
  source_port_range           = "*"
  destination_address_prefix  = "*"
  destination_port_range      = "*"
  resource_group_name         = azurerm_resource_group.my_rg.name
  network_security_group_name = azurerm_network_security_group.websocket_nsg.name
}

# 🔹NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "websocket_nsg_association" {
  subnet_id                 = azurerm_subnet.private_link_subnet.id
  network_security_group_id = azurerm_network_security_group.websocket_nsg.id
}
