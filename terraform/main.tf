provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# التحقق مما إذا كان Resource Group موجودًا
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

# التحقق مما إذا كان ACR موجودًا
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

# استبدال `azurerm_app_service_plan` بـ `azurerm_service_plan`
resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  os_type             = "Linux"
  sku_name            = "B1"
}

# استبدال `azurerm_app_service` بـ `azurerm_linux_web_app`
resource "azurerm_linux_web_app" "web_app" {
  name                = "my-fastapi-websocket-app"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  service_plan_id     = azurerm_service_plan.app_service_plan.id  

  site_config {
    linux_fx_version = "DOCKER|${coalesce(try(azurerm_container_registry.my_acr[0].login_server, ""), data.azurerm_container_registry.existing_acr.login_server)}/fastapi-websocket:latest"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://${coalesce(try(azurerm_container_registry.my_acr[0].login_server, ""), data.azurerm_container_registry.existing_acr.login_server)}"
    DOCKER_REGISTRY_SERVER_USERNAME     = coalesce(try(azurerm_container_registry.my_acr[0].admin_username, ""), data.azurerm_container_registry.existing_acr.admin_username)
    DOCKER_REGISTRY_SERVER_PASSWORD     = coalesce(try(azurerm_container_registry.my_acr[0].admin_password, ""), data.azurerm_container_registry.existing_acr.admin_password)
  }
}

