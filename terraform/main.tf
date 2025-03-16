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
  location = "west europe"

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
  location            = "west europe"
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

# التحقق مما إذا كان App Service موجودًا
data "azurerm_app_service" "existing_app_service" {
  name                = "my-websocket-app"
  resource_group_name = "myResourceGroupTR"
}

resource "azurerm_app_service" "my_app_service" {
  count               = length(data.azurerm_app_service.existing_app_service.id) > 0 ? 0 : 1
  name                = "my-websocket-app"
  location            = "West Europe"
  resource_group_name = "myResourceGroupTR"
  app_service_plan_id = azurerm_app_service_plan.my_plan.id

  site_config {
    linux_fx_version = "DOCKER|myacrTR202.azurecr.io/fastapi-websocket:latest"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_app_service_plan" "my_plan" {
  name                = "my-appservice-plan"
  location            = "West Europe"
  resource_group_name = "myResourceGroupTR"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Basic"
    size = "B1"
  }
}
