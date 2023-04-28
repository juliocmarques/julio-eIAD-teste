output "id" {
  value = azurerm_log_analytics_workspace.log_analytics.id
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics.workspace_id
}

output "primary_shared_key" {
  value = azurerm_log_analytics_workspace.log_analytics.primary_shared_key
}

output "instrumentation_key" {
  value = azurerm_application_insights.eiad.instrumentation_key
}

output "instrumentation_connection_string" {
  value = azurerm_application_insights.eiad.connection_string
}