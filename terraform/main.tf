provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_resource_group" "rg2" {
  name     = var.rg_name
  location = var.location
}
