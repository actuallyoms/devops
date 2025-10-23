terraform {
  backend "azurerm" {
    resource_group_name  = "tfstatesa-rg"    # senin state RG'si
    storage_account_name = "tfstatedevopsomer"     # senin Storage Account adı
    container_name       = "tfstate"              # senin container adı
    key                  = "terraform.tfstate"    # state dosyasının blob içindeki adı
  }
}
