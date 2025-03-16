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

# إنشاء App Service Plan
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

# التحقق مما إذا كان App Service موجودًا باستخدام `az api`
locals {
  app_service_exists = try(length(jsondecode(data.external.check_app_service.result.app_service)), 0) > 0
}

data "external" "check_app_service" {
  program = ["bash", "-c", <<EOT
    az webapp show --name my-websocket-app --resource-group myResourceGroupTR --query id --output json || echo '{}'
  EOT
  ]
}

# إنشاء App Service فقط إذا لم يكن موجودًا
resource "azurerm_app_service" "my_app_service" {
  count               = local.app_service_exists ? 0 : 1
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
 
