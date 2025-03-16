variable "Subscription_id" {
  type    = string
  default = "2204702f-2344-4ad7-acc5-63b9daea47de"
}

variable "azurerm_linux_web_app_name" {
  type = string
}

variable "azurerm_linux_web_app_resource_group_name" {
  type = string
}

variable "azurerm_linux_web_app_location" {
  type = string
}

variable "azurerm_linux_web_app_azurerm_service_plan_id" {
  type = string
}

variable "azurerm_linux_web_app_app_docker_image" {
  type = string
}

variable "azurerm_linux_web_app_docker_registry_url" {
  type = string
}

variable "docker_registry_username" {
  type = string
}

variable "docker_registry_password" {
  type = string
}

