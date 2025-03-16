provider "azurerm" {
  features {}
  subscription_id = var.Subscription_id
}

# جلب معرف Resource Group إذا كان موجودًا
data "azurerm_resource_group" "existing_rg" {
  name = "myResourceGroupTR"
}

resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroupTR"
  location = "west europe"

  lifecycle {
    ignore_changes = [tags]
  }
}

# جلب معرف Container Registry إذا كان موجودًا
data "azurerm_container_registry" "existing_acr" {
  name                = "myacrTR202"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}

resource "azurerm_container_registry" "my_acr" {
  name                = "myacrTR202"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
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
