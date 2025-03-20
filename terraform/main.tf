provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# 🔹 Check if Resource Group exists
data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroupTR"
}

resource "azurerm_resource_group" "my_rg" {
  count    = try(data.azurerm_resource_group.existing_rg.name, null) != null ? 0 : 1
  name     = "myResourceGroupTR"
  location = "West Europe"

  lifecycle {
    ignore_changes = [tags]
  }
}

# 🔹 Check if ACR exists
data "azurerm_container_registry" "existing_acr" {
  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
}

resource "azurerm_container_registry" "my_acr" {
  count               = try(data.azurerm_container_registry.existing_acr.name, null) != null ? 0 : 1
  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
  location            = "West Europe"
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

# 🔹 Check if App Service Plan exists
data "azurerm_service_plan" "existing_app_service_plan" {
  name                = "myAppServicePlan"
  resource_group_name = "myResourceGroupTR"
}

resource "azurerm_service_plan" "app_service_plan" {
  count = try(data.azurerm_service_plan.existing_app_service_plan.name, null) != null ? 0 : 1

  name                = "myAppServicePlan"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, null), try(data.azurerm_resource_group.existing_rg.location, "West Europe"))
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, null), data.azurerm_resource_group.existing_rg.name)
  os_type             = "Linux"
  sku_name            = "B1"
}

# 🔹 Check if Web App exists
data "azurerm_linux_web_app" "existing_web_app" {
  name                = "my-fastapi-websocket-app"
  resource_group_name = "myResourceGroupTR"
}

resource "azurerm_linux_web_app" "web_app" {
  count = try(data.azurerm_linux_web_app.existing_web_app.name, null) != null ? 0 : 1

  name                = "my-fastapi-websocket-app"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, null), try(data.azurerm_resource_group.existing_rg.location, "West Europe"))
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, null), data.azurerm_resource_group.existing_rg.name)
  service_plan_id     = coalesce(try(azurerm_service_plan.app_service_plan[0].id, null), try(data.azurerm_service_plan.existing_app_service_plan.id, null))

  site_config {
    application_stack {
      docker_image_name = "${coalesce(try(azurerm_container_registry.my_acr[0].login_server, null), try(data.azurerm_container_registry.existing_acr.login_server, ""))}/fastapi-websocket:latest"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
}

# 🔹 Private Endpoint Setup
data "azurerm_virtual_network" "existing_vnet" {
  name                = "my-vnet"
  resource_group_name = "myResourceGroupTR"
}

data "azurerm_subnet" "existing_private_subnet" {
  count                = try(data.azurerm_virtual_network.existing_vnet.name, null) != null ? 1 : 0
  name                 = "private-endpoint-subnet"
  resource_group_name  = "myResourceGroupTR"
  virtual_network_name = try(data.azurerm_virtual_network.existing_vnet.name, "")
}

resource "azurerm_private_endpoint" "acr_private_endpoint" {
  count               = try(data.azurerm_subnet.existing_private_subnet[0].name, null) != null ? 1 : 0
  name                = "acr-private-endpoint"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, null), try(data.azurerm_resource_group.existing_rg.location, "West Europe"))
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, null), data.azurerm_resource_group.existing_rg.name)
  subnet_id           = try(data.azurerm_subnet.existing_private_subnet[0].id, "")

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = coalesce(try(azurerm_container_registry.my_acr[0].id, null), try(data.azurerm_container_registry.existing_acr.id, null))
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
