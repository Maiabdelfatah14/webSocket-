variable "region" {
  type    = string
  default = "west europe"
}

variable "AZURE_SUBSCRIPTION_ID" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "AZURE_CLIENT_ID" {
  description = "The Azure Client ID"
  type        = string
}

variable "AZURE_CLIENT_SECRET" {
  description = "The Azure Client Secret"
  type        = string
  sensitive   = true  # لأن هذا سر يجب أن يكون محمي
}

variable "AZURE_TENANT_ID" {
  description = "The Azure Tenant ID"
  type        = string
}
