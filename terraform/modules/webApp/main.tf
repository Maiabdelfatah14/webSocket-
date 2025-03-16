
resource "azurerm_linux_web_app" "example" {
  name                = var.azurerm_linux_web_app_name # name of the web app
  resource_group_name = var.azurerm_linux_web_app_resource_group_name
  location            = var.azurerm_linux_web_app_azurerm_service_plan_location
  # service_plan_id     = azurerm_service_plan.example.id #The ID of the service plan that this web app will use
  service_plan_id     = var.azurerm_linux_web_app_azurerm_service_plan_id
  app_settings        = var.azurerm_linux_web_app_app_settings
  client_affinity_enabled = var.azurerm_linux_web_app_client_affinity_enabled
  https_only = var.azurerm_linux_web_app_https_only #https_only - (Optional) Should the Linux Web App require HTTPS connections. Defaults to false
  # default_hostname = "buraq"
 

  site_config {

   application_stack {
    docker_image_name        = var.azurerm_linux_web_app_app_docker_image
    docker_registry_url      = var.azurerm_linux_web_app_docker_registry_url
    
  }

  dynamic "cors" {
    for_each = var.enable_cors ? [1] : []
    content {
      allowed_origins = var.allowed_origins
      support_credentials = var.support_credentials
    }
  }

    auto_heal_setting {
      trigger {
        status_code {
          status_code_range = var.azurerm_linux_web_app_status_code_range
          count             = var.azurerm_linux_web_app_status_code_count
          interval          = var.azurerm_linux_web_app_status_code_interval
        }
      }

      action {
        action_type = var.azurerm_linux_web_app_action_type
      }
    }
  }


}


resource "null_resource" "update_webapp_settings" {
  provisioner "local-exec" {
    command = <<EOT
      az webapp config appsettings set \
        --resource-group ${var.azurerm_linux_web_app_resource_group_name} \
        --name ${var.azurerm_linux_web_app_name} \
        --settings \
          DOCKER_REGISTRY_SERVER_USERNAME=${var.docker_registry_username} \
          DOCKER_REGISTRY_SERVER_PASSWORD=${var.docker_registry_password}
    EOT
  }

  depends_on = [azurerm_linux_web_app.example]
}

resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.example.id
  subnet_id      = "/subscriptions/2f4948bc-9b84-4096-afe5-74912dd1ff47/resourceGroups/buraq_network/providers/Microsoft.Network/virtualNetworks/buraq_network/subnets/buraq_publicSubnet6"
}


output "default_hostname" {
  description = "The default hostname of the Azure Linux Web App."
  value       = azurerm_linux_web_app.example.default_hostname
}


######################################
