provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "my_rg" {
  name     = "myResourceGroup"
  location = "west europe"  
}


resource "azurerm_container_registry" "my_acr" {
  name                = "myacr"
  resource_group_name = azurerm_resource_group.my_rg.name
  location            = azurerm_resource_group.my_rg.location
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "myakscluster"
  location            = azurerm_resource_group.my_rg.location  
  resource_group_name = azurerm_resource_group.my_rg.name    
  dns_prefix          = "myaks"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    environment = "production"
  }
}
