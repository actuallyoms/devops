provider "azurerm" {
  features {}
}

# --- Resource Group ---

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_name}-dns"

  # Default / system node pool (zorunlu)
  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"
    node_count = 1

    node_labels = {
      tier = "production"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # OIDC ve workload identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Key Vault Secrets Provider (CSI) addon
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = {
    environment = "production"
  }
}

# Worker node pools
# 2 adet production worker (her biri 1 node olacak)
resource "azurerm_kubernetes_cluster_node_pool" "worker_prod" {
  count                 = 2
  name                  = "workerprod${count.index + 1}"   # workerprod1, workerprod2 (her ikisi 1-12 char içinde)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  mode                  = "User"

  node_labels = {
    tier = "production"
  }
}

# 1 adet test worker
resource "azurerm_kubernetes_cluster_node_pool" "worker_test" {
  name                  = "workertest"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  mode                  = "User"

  node_labels = {
    tier = "test"
  }
}


