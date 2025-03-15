provider "azurerm" {
  features {}
}

resource "azurerm_container_registry" "my_acr" {
  name                = "myregistry"
  location            = "East US"
  resource_group_name = azurerm_resource_group.my_rg.name
  sku                 = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = "myakscluster"
  location            = "East US"
  resource_group_name = azurerm_resource_group.my_rg.name
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_DS2_v2"
  }
  identity {
    type = "SystemAssigned"
  }
}
