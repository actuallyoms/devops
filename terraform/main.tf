provider "azurerm" {
  features {}
}

# --- Resource Group ---

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}


# --- AKS Cluster Tanımı ---

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.aks_name}-dns"

  # 1️⃣ SYSTEM NODE POOL (1 node)
  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"   # düşük maliyetli, 2 CPU, 7 GB RAM
    node_count = 1
    mode       = "System"

    node_labels = {
      tier = "production"
    }
  }

  # 2️⃣ Kimlik (Identity)
  identity {
    type = "SystemAssigned"
  }

  # 3️⃣ OIDC ve Workload Identity aktif etme
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # 4️⃣ Key Vault CSI Driver (Secrets Store Provider)
  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  # 5️⃣ Ağ profili (network ayarları)
  network_profile {
    network_plugin = "azure"   # Azure CNI aktif
  }

  tags = {
    environment = "production"
  }
}

# --- 6️⃣ USER NODE POOL (4 node) ---
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = "workerpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"   # düşük maliyetli, 2 CPU, 7 GB RAM
  node_count            = 4
  mode                  = "User"

  node_labels = {
    tier = "production"
  }

  tags = {
    purpose = "app-workers"
  }
}

