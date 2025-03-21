provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# 🔹 Import or Create Resource Group
resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroupTR"
  location = "East US"

  lifecycle {
    prevent_destroy = true  
    ignore_changes  = [tags]
  }
}


# 🔹 Create ACR
resource "azurerm_container_registry" "my_acr" {
  name                = "myacrTR202"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}

# 🔹 Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  os_type             = "Linux"
  sku_name            = "B1"

  lifecycle {
    ignore_changes = [tags]
  }
}

# 🔹 Create Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "my-fastapi-websocket-app"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  service_plan_id     = azurerm_service_plan.app_service_plan.id

  site_config {
    application_stack {
      docker_image_name = "${azurerm_container_registry.my_acr.login_server}/fastapi-websocket:latest"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
  }

  lifecycle {
    ignore_changes = [app_settings, site_config]
  }
}

# 🔹 Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  address_space       = ["10.0.0.0/16"]
}

# 🔹 Create Subnet for Private Endpoint
resource "azurerm_subnet" "private_subnet" {
  name                 = "myPrivateSubnet"
  resource_group_name  = azurerm_resource_group.my_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 🔹 Create Private Endpoint for ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "acr-private-endpoint"
  location            = azurerm_resource_group.my_rg.location
  resource_group_name = azurerm_resource_group.my_rg.name
  subnet_id           = azurerm_subnet.private_subnet.id

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.my_acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
