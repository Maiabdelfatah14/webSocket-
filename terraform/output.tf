output "web_app_name" {
  description = "The name of the Azure  Websocket App"
  value       = fastapi-websocket
}

output "web_app_default_hostname" {
  description = "The default hostname of the Azure Linux Web App"
  value       = fastapi-websocket.default_hostname
}
