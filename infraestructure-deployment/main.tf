resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location_zone
}

resource "azurerm_container_registry" "acr" {
  name                = "glgacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "laws"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-06-01-preview"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = "aca-env"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.loganalytics.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.loganalytics.primary_shared_key
        }
      }
    }
  })
}

resource "azapi_resource" "aca" {
  type      = "Microsoft.App/containerapps@2022-06-01-preview"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = "aca"

  body = jsonencode({
    properties : {
      environmentId = azapi_resource.containerapp_environment.id
      configuration = {
        activeRevisionsMode = "Single"
        secrets = [
          {
            name  = "reg-pswd-2480efc7-b65f"
            value = var.secret_value
          }
        ]
        ingress = {
          external      = true
          targetPort    = 8000
          transport     = "auto"
          allowInsecure = true
        }
        registries = [
          {
            username          = "glgacr"
            passwordSecretRef = "reg-pswd-2480efc7-b65f"
            server            = "glgacr.azurecr.io"
          }
        ]
      }
      template = {
        containers = [
          {
            name  = "main-app"
            image = "glgacr.azurecr.io/app:latest"
            resources = {
              cpu    = 0.25
              memory = ".5Gi"
            }
          }
        ]
        scale = {
          minReplicas = 2
          maxReplicas = 5
        }
      }
    }
  })
}
