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
  location            = azurerm_resource_group.rg.location  # RG lokasyonu
  resource_group_name = azurerm_resource_group.rg.name      # RG adı
  dns_prefix          = "${var.aks_name}-dns"

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # OIDC ve Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Key Vault CSI Driver
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  # Network
  network_profile {
    network_plugin = "azure"   # Azure CNI aktif
  }

  tags = {
    environment = "production"
  }
}

# USER NODE POOL (4 node)
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = "workerpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"  # düşük maliyetli
  node_count            = 4
  mode                  = "User"

  node_labels = {
    tier = "production"
  }

  tags = {
    purpose = "app-workers"
  }
}
