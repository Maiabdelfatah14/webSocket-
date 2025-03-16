# modules/static_web_app/outputs.tf
output "web_app_name" {
  description = "The name of the Azure Linux Web App"
  value       = azurerm_linux_web_app.example.name
}

output "web_app_default_hostname" {
  description = "The default hostname of the Azure Linux Web App"
  value       = azurerm_linux_web_app.example.default_hostname
}

# output "web_app_outbound_ip_addresses" {
#   description = "The outbound IP addresses of the Azure Linux Web App"
#   value       = azurerm_linux_web_app.example.outbound_ip_addresses
# }

# output "web_app_possible_outbound_ip_addresses" {
#   description = "The possible outbound IP addresses of the Azure Linux Web App"
#   value       = azurerm_linux_web_app.example.possible_outbound_ip_addresses
# }

# output "web_app_site_credentials" {
#   description = "The site credentials for the Azure Linux Web App"
#   value       = azurerm_linux_web_app.example.site_credential
#   sensitive   = true # Marks this output as sensitive (e.g., passwords)
# }

