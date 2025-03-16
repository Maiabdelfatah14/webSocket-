variable "Subscription_id" {
  type    = string
  default = "2204702f-2344-4ad7-acc5-63b9daea47de"
}


variable "Websocket_status_worker_release_azurerm_service_plan_name" {
  type = string
  default = "ASP-Websocketnetwork-bdba"
}



variable "Websocket_status_worker_release_azurerm_service_plan_location" {
  type = string
  default = "UAE North"
}


variable "Websocket_status_worker_release_service_plan_id" {
 description = "The ID of the service plan for the Linux Web App."
  type        = string
  default     = "/subscriptions/2f4948bc-9b84-4096-afe5-74912dd1ff47/resourceGroups/Websocket_network/providers/Microsoft.Web/serverFarms/ASP-Websocketnetwork-bdba"
}


variable "Websocket_status_worker_release_name" {
  type = string
  default = "Websocket-status-worker-release"
}

variable "Websocket_status_worker_docker_image" {
  type = string
  default = "Websocket-status-worker-release:latest"
}



variable "Websocket_status_worker_release_client_affinity_enabled" {
  type = bool
   default = "true"
  
}

variable "Websocket_status_worker_release_https_only" {
  
  type = bool
   default = "true"
}

variable "Websocket_status_worker_release_status_code_range"{
  type = string
  default = "500-599"
}

variable "Websocket_status_worker_release_status_code_count"{
  type = string
  default = "10"
}

variable "Websocket_status_worker_release_status_code_interval"{
  type = string
  default = "00:05:00"
}


variable "Websocket_status_worker_release_action_type"{
  type = string
  default = "Recycle"
}

# action_type = "Recycle"
variable "Websocket_status_worker_release_app_settings" {
  description = "A map of key-value pairs for the app settings of the Linux Web App."
  type        = map(string)
  default     = {
    
    BOT_QUEUE                           = "bot_queue"
   

  }
}


variable "Websocket_status_worker_release__docker_tag" {
  description = "The Docker image tag for the Azure Linux Web App."
  type        = string
  default = "latest"
}

variable "Websocket_status_workerdocker_registry_url"{
  type        = string
  default = "https://myacrTR202.azurecr.io"
}


