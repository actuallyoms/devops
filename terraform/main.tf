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

  # Default/System Node Pool (zorunlu)
  default_node_pool {
    name       = "systempool"
    vm_size    = "Standard_DS2_v2"
    node_count = 1

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

# USER NODE POOL (3 worker node)
resource "azurerm_kubernetes_cluster_node_pool" "workers" {
  name                  = "workerpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 3
  mode                  = "User"

  # Node bazlı label'lar için ayrı ayrı node pool kullanmamız gerekiyor.
  # Terraform tek node pool içinde farklı label veremez, o yüzden 3 ayrı pool yapacağız:
}

# --- Worker 1 ve 2: tier=production ---
resource "azurerm_kubernetes_cluster_node_pool" "worker_prod" {
  count                 = 2
  name                  = "worker-prod-${count.index + 1}"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  mode                  = "User"

  node_labels = {
    tier = "production"
  }
}

# --- Worker 3: tier=test ---
resource "azurerm_kubernetes_cluster_node_pool" "worker_test" {
  name                  = "worker-test"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = "Standard_DS2_v2"
  node_count            = 1
  mode                  = "User"

  node_labels = {
    tier = "test"
  }
}

