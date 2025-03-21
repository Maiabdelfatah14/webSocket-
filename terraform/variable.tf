#variable "Subscription_id" {
 # type    = string
  #default = "2204702f-2344-4ad7-acc5-63b9daea47de"}


variable "subscription_id" {default = "2204702f-2344-4ad7-acc5-63b9daea47de"}
variable "resource_group_name" { default = "myResourceGroupTR" }
variable "location" { default = "East US" }
variable "acr_name" { default = "myacrTR202" }
variable "app_service_name" { default = "my-fastapi-websocket-app" }
variable "app_service_plan_name" { default = "myAppServicePlan" }
