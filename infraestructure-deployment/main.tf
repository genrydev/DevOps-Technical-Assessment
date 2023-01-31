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
  
  body   = jsonencode({
    properties = { 
      appLogsConfiguration = {
        destination               = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = azurerm_log_analytics_workspace.loganalytics.workspace_id
          sharedKey  = azurerm_log_analytics_workspace.loganalytics.primary_shared_key
        }
      }
    }
 })
}

# resource "azapi_resource" "aca" {
#   for_each  = { for ca in var.container_apps: ca.name => ca}
#   type = "Microsoft.App/containerApps@2022-03-01"
  
#   parent_id = azurerm_resource_group.rg.id
#   location  = azurerm_resource_group.rg.location
#   name      = each.value.name
#   tags = each.value.tag
  
#   body = jsonencode({
#     properties: {
#       managedEnvironmentId = azapi_resource.aca_env.id
#       configuration = {
#         ingress = {
#           external = each.value.ingress_enabled
#           targetPort = each.value.ingress_enabled?each.value.containerPort: null
#         }
#         registries = {
#           identity = "system"
#           passwordSecretRef = ""
#           server = ""
#         }
#       }
#       template = {
#         containers = [
#           {
#             name = "main"
#             image = "${each.value.image}:${each.value.tag}"
#             resources = {
#               cpu = each.value.cpu_requests
#               memory = each.value.mem_requests
#             }
#           }         
#         ]
#         scale = {
#           minReplicas = each.value.min_replicas
#           maxReplicas = each.value.max_replicas
#         }
#       }
#     }
#   })  
# }