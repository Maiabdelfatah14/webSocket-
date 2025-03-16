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

resource "azurerm_websocker_app" "example" {
  name                = var.azurer_websocker_app
  resource_group_name = var.app_resource_group
  location            = var.app_location
  service_plan_id     = var.app_azurerm_service_plan
  https_only          = var.app_https_only

  site_config {
    application_stack {
      docker_image_name   = var.app_docker_image
      docker_registry_url = var.app_docker_registry_url
    }
  }
}

