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