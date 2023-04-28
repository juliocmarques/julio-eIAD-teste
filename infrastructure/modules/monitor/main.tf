resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "random_uuid" "workbook_system_overview_id" {
}

data "template_file" "workbook" {
  template = file("${path.module}/workbook.template.json")
}

resource "azurerm_resource_group_template_deployment" "workbook_system_overview" {
  name                = "azure_monitor_workbook_system_overview"
  resource_group_name = var.resource_group_name
  deployment_mode     = "Incremental"
  template_content    = data.template_file.workbook.template
  parameters_content = jsonencode({
    "workbookDisplayName" : { value = "eIAD v0.1 - ${var.resource_group_name}" },
    "workbookId" : { value = random_uuid.workbook_system_overview_id.result },
    "workbookContent" : { value = file("${path.module}/Azure_Synapse_Spark_Application.workbook") },
    "workbookSourceId" : { value = "${azurerm_log_analytics_workspace.log_analytics.id}" },
    "tags" : { value = var.tags }
  })
  depends_on = [azurerm_log_analytics_workspace.log_analytics]
}

resource "azurerm_application_insights" "eiad" {
  name                = var.insight_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"
  tags                = var.tags
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
}