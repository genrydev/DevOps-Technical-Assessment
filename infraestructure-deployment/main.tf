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

resource "azapi_resource" "catest" {
  type      = "Microsoft.App/containerapps@2022-06-01-preview"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = "catest"

  body = jsonencode({
    properties = {
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

resource "azapi_resource" "caprod" {
  type      = "Microsoft.App/containerapps@2022-06-01-preview"
  parent_id = azurerm_resource_group.rg.id
  location  = azurerm_resource_group.rg.location
  name      = "caprod"

  body = jsonencode({
    properties = {
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

# Get data from Container Apps

data "azapi_resource" "test_custom_domain" {
  name      = "test_custom_domain"
  parent_id = azapi_resource.catest.id
  type      = "Microsoft.App/containerapps@2022-06-01-preview"

  response_export_values = ["properties.outboundIpAddresses", "properties.customDomainVerificationId"]
}

data "azapi_resource" "prod_custom_domain" {
  name      = "prod_custom_domain"
  parent_id = azapi_resource.caprod.id
  type      = "Microsoft.App/containerapps@2022-06-01-preview"

  response_export_values = ["properties.outboundIpAddresses", "properties.customDomainVerificationId"]
}


# Custom Domains

resource "azurerm_dns_zone" "genryapitest" {
  name                = "genryapitest.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_zone" "genryapiprod" {
  name                = "genryapiprod.com"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "test_a_record" {
  name                = "test_a_record"
  zone_name           = azurerm_dns_zone.genryapitest.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [
    jsondecode(data.azapi_resource.test_custom_domain.output).properties.outboundIpAddresses
  ]
}

resource "azurerm_dns_a_record" "prod_a_record" {
  name                = "prod_a_record"
  zone_name           = azurerm_dns_zone.genryapiprod.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [
    jsondecode(data.azapi_resource.prod_custom_domain.output).properties.outboundIpAddresses
  ]
}

resource "azurerm_dns_txt_record" "test_txt_record" {
  name                = "test_txt_record"
  zone_name           = azurerm_dns_zone.genryapitest.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record { value = "asuis" }
  record {
    value = jsondecode(data.azapi_resource.test_custom_domain.output).properties.customDomainVerificationId
  }
  tags = { environment = "test" }
}

resource "azurerm_dns_txt_record" "prod_txt_record" {
  name                = "prod_txt_record"
  zone_name           = azurerm_dns_zone.genryapiprod.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300

  record { value = "asuis" }
  record {
    value = jsondecode(data.azapi_resource.prod_custom_domain.output).properties.customDomainVerificationId
  }
  tags = { environment = "production" }
}