provider "azurerm" {
  features {}

  subscription_id = var.Subscription_id
}

resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroup-1"
  location = "west europe"  
}


resource "azurerm_container_registry" "my_acr" {
  name                = "myacr"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  sku                 = "Basic"
}
  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}


