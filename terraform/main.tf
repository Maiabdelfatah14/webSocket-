provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# 🔹 Fetch existing Resource Group, if not found, create it
  resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroupTR"
  location = "East US"
}

# 🔹 Create ACR
resource "azurerm_container_registry" "my_acr" {
  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
  location = "East US"
  sku                 = "Premium"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 🔹 Create App Service Plan
resource "azurerm_service_plan" "app_service_plan" {
  name                = "myAppServicePlan"
  resource_group_name = "myResourceGroupTR"
  location = "East US"
  os_type             = "Linux"
  sku_name            = "B1"
}

# 🔹 Create Web App
resource "azurerm_linux_web_app" "web_app" {
  name                = "my-fastapi-websocket-app"
  resource_group_name = "myResourceGroupTR"
  location = "East US"
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
}

# 🔹 Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "myVNet"
  resource_group_name = "myResourceGroupTR"
  location = "East US"
  address_space       = ["10.0.0.0/16"]
}

# 🔹 Create Subnet for Private Endpoint
resource "azurerm_subnet" "private_subnet" {
  name                 = "myPrivateSubnet"
  resource_group_name  = "myResourceGroupTR"
  virtual_network_name = "myVNet"
  address_prefixes     = ["10.0.1.0/24"]
}

# 🔹 Create Private Endpoint for ACR
resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "acr-private-endpoint"
  location = "East US"
  resource_group_name = "myResourceGroupTR"
  subnet_id           = azurerm_subnet.private_subnet.id

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.my_acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}
