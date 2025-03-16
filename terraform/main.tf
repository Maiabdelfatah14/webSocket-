provider "azurerm" {
  features {}
    subscription_id = var.Subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = "myResourceGroup"
  location = "East US"
}

resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "myAppServicePlan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true
  sku {
    tier = "Basic"
    size = "B1"
  }
}

resource "azurerm_app_service" "appservice" {
  name                = "mywebsocketapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.appserviceplan.id

  site_config {
    linux_fx_version = "DOCKER|myacrname.azurecr.io/mywebsocketapp:${var.image_tag}"
  }

  app_settings = {
    DOCKER_REGISTRY_SERVER_URL      = "https://myacrname.azurecr.io"
    DOCKER_REGISTRY_SERVER_USERNAME = "myacrname"
    DOCKER_REGISTRY_SERVER_PASSWORD = "your-acr-password"
  }
}

variable "image_tag" {}


