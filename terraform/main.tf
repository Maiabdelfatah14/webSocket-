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

module "websocketapp"{
    source = "./modules/webApp"
    
    azurerm_linux_web_app_name                               = var.Websocket_status_worker_release_name
    # azurerm_linux_web_app_resource_group_name= module.Websocket_releaseResourceGroub.azurerm_resource_group_name
    # azurerm_linux_web_app_location = module.Websocket_releaseResourceGroub.azurerm_resource_group_location
    azurerm_linux_web_app_resource_group_name                = data.azurerm_resource_group.my_rg.name
    azurerm_linux_web_app_location                           = data.azurerm_resource_group.my_rg.location
    azurerm_linux_web_app_azurerm_service_plan_location      = var.Websocket_status_worker_release_azurerm_service_plan_location
    azurerm_linux_web_app_azurerm_service_plan_name          = var.Websocket_status_worker_release_azurerm_service_plan_name
    azurerm_linux_web_app_azurerm_service_plan_id            = var.Websocket_status_worker_release_service_plan_id
    azurerm_linux_web_app_client_affinity_enabled            = var.Websocket_status_worker_release_client_affinity_enabled
    azurerm_linux_web_app_app_settings                       = var.Websocket_status_worker_release_app_settings
    azurerm_linux_web_app_https_only                         = var.Websocket_status_worker_release_https_only
    azurerm_linux_web_app_status_code_range                  = var.Websocket_status_worker_release_status_code_range
    azurerm_linux_web_app_status_code_count                  = var.Websocket_status_worker_release_status_code_count
    azurerm_linux_web_app_status_code_interval               = var.Websocket_status_worker_release_status_code_interval
    azurerm_linux_web_app_action_type                        = var.Websocket_status_worker_release_action_type
    azurerm_linux_web_app_app_docker_image                   = var.Websocket_status_worker_docker_image
    azurerm_linux_web_app_docker_registry_url                = var.Websocket_status_workerdocker_registry_url  
    
    azurerm_linux_web_app_docker_registry_password           = data.azurerm_container_registry.existing_acr.admin_password
    # https://<acr-name>.azurecr.io
    docker_registry_password                                 = data.azurerm_container_registry.existing_acr.admin_password
    docker_registry_username                                 = data.azurerm_container_registry.existing_acr.admin_username 
    
}




