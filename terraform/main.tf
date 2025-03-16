provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# جلب معرف Resource Group إذا كان موجودًا
data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroupTR"
}

# إنشاء Resource Group فقط إذا لم تكن موجودة
resource "azurerm_resource_group" "my_rg" {
  count = length(data.azurerm_resource_group.existing_rg.id) > 0 ? 0 : 1
  
  name     = "myResourceGroupTR"
  location = "west europe"

  lifecycle {
    ignore_changes = [tags]
  }
}

# جلب معرف Container Registry إذا كان موجودًا
data "azurerm_container_registry" "existing_acr" {
  name                = "myacrTR202"
  resource_group_name = "myResourceGroupTR"
}

# إنشاء Container Registry فقط إذا لم يكن موجودًا
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

