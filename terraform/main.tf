provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# 🔹 Resource Group (Existing Resource)
resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroupTR"
  location = "East US"

  lifecycle {
    ignore_changes  = [tags]
  }
}

# 🔹 Azure Container Registry (Existing Resource)
resource "azurerm_container_registry" "my_acr" {
  name                = "myacrTR202"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes  = [tags]
  }
}

# 🔹 App Service Plan (Existing Resource)
resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  os_type             = "Linux"
  sku_name            = "B1"

  lifecycle {
    ignore_changes  = [tags]
  }
}

# 🔹 Virtual Network (Existing Resource)
resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  address_space       = ["10.0.0.0/16"]

  lifecycle {
    ignore_changes  = [tags]
  }
}
