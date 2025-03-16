provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroupTR"
}

resource "azurerm_resource_group" "my_rg" {
  count = length(data.azurerm_resource_group.existing_rg.id) > 0 ? 0 : 1
  
  name     = "myResourceGroupTR"
  location = "West Europe"

  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_container_registry" "existing_acr" {
  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
}

resource "azurerm_container_registry" "my_acr" {
  count = length(data.azurerm_container_registry.existing_acr.id) > 0 ? 0 : 1

  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
  location            = "West Europe"
  sku                 = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  os_type             = "Linux"
  sku_name            = "B1"
}

resource "azurerm_linux_web_app" "web_app" {
  name                = "my-fastapi-websocket-app"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  service_plan_id     = azurerm_service_plan.app_service_plan.id  

  site_config {
    application_stack {
      docker_image_name = "${coalesce(try(azurerm_container_registry.my_acr[0].login_server, ""), data.azurerm_container_registry.existing_acr.login_server)}/fastapi-websocket:latest"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }
}

