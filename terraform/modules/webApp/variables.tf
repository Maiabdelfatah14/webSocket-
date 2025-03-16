variable "azurerm_linux_web_app_azurerm_service_plan_name" {
  type = string
}


variable "azurerm_linux_web_app_azurerm_service_plan_location" {
  type = string
}


variable "azurerm_linux_web_app_azurerm_service_plan_id" {
  type = string
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


variable "azurerm_linux_web_app_app_settings" {
  type = map(string)
}

variable "azurerm_linux_web_app_https_only" {
  
  type = bool
}

variable "azurerm_linux_web_app_client_affinity_enabled" {
  type = bool
}

variable "azurerm_linux_web_app_status_code_range"{
  type = string
}

variable "azurerm_linux_web_app_status_code_count"{
  type = string
}

variable "azurerm_linux_web_app_status_code_interval"{
  type = string
}

#  status_code_range = "500-599"
#           count             = 10
#           interval          = "00:05:00"

variable "azurerm_linux_web_app_action_type"{
  type = string
}



variable "azurerm_linux_web_app_app_docker_image" {
  description = "The Docker image name for the Azure Linux Web App."
  type        = string
}

variable "azurerm_linux_web_app_docker_registry_url" {
  description = "The Docker image tag for the Azure Linux Web App."
  type        = string
}

variable "azurerm_linux_web_app_docker_registry_password"{
  type = string
}

variable "docker_registry_username" {
  type = string
}

variable "docker_registry_password" {
  type = string
}



variable "enable_cors" {
  description = "Enable CORS settings for the web app"
  type        = bool
  default     = false
}

variable "allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = []
}

variable "support_credentials" {
  description = "Enable support for credentials in CORS"
  type        = bool
  default     = false
}





#######################################################
# variable "ado_pat" {
#   description = "The tenant ID for Azure authentication."
#   type        = string
# }

# variable "ado_org" {
#   description = "The tenant ID for Azure authentication."
#   type        = string
# }

# variable "ado_project" {
#   description = "The tenant ID for Azure authentication."
#   type        = string
# }

# variable "ado_pipeline_id" {
#   description = "The tenant ID for Azure authentication."
#   type        = string
# }


# variable "service_principal_client_id" {
#   description = "The client ID of the service principal for Azure authentication."
#   type        = string
# }

# variable "service_principal_client_secret" {
#   description = "The client secret of the service principal for Azure authentication."
#   type        = string
#   sensitive   = true
# }

# variable "tenant_id" {
#   description = "The tenant ID for Azure authentication."
#   type        = string
# }

# variable "repository_name" {
#   description = "The name of the repository to create in the Azure Container Registry."
#   type        = string
#   # default     = "my-repo" # Default repository name
# }