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

# جلب معلومات الـ App Service Plan إذا كان موجودًا
data "azurerm_service_plan" "existing_app_service_plan" {
  name                = "myAppServicePlan"
  resource_group_name = "myResourceGroupTR"
}

# جلب معلومات الـ Web App إذا كان موجودًا
data "azurerm_linux_web_app" "existing_web_app" {
  name                = "my-fastapi-websocket-app"
  resource_group_name = "myResourceGroupTR"
}

# إذا لم يكن الـ App Service Plan موجودًا، قم بإنشائه
resource "azurerm_service_plan" "app_service_plan" {
  count               = length(data.azurerm_service_plan.existing_app_service_plan.id) > 0 ? 0 : 1
  name                = "myAppServicePlan"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  os_type             = "Linux"
  sku_name            = "B1"
}

# إذا لم يكن الـ Web App موجودًا، قم بإنشائه
resource "azurerm_linux_web_app" "web_app" {
  count               = length(data.azurerm_linux_web_app.existing_web_app.id) > 0 ? 0 : 1
  name                = "my-fastapi-websocket-app"
  location            = coalesce(try(azurerm_resource_group.my_rg[0].location, ""), data.azurerm_resource_group.existing_rg.location)
  resource_group_name = coalesce(try(azurerm_resource_group.my_rg[0].name, ""), data.azurerm_resource_group.existing_rg.name)
  service_plan_id     = azurerm_service_plan.app_service_plan[count.index].id  # تعديل هنا لاستخدام count.index

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






resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "private_subnet" {
  name                 = "private-endpoint-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  enforce_private_link_endpoint_network_policies = true
}



resource "azurerm_private_endpoint" "acr_private_endpoint" {
  name                = "acr-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.private_subnet.id

  private_service_connection {
    name                           = "acr-privatelink"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}


