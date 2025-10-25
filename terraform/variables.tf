
variable "location" {
  description = "Azure lokasyonu"
  type        = string
  default     = "westeurope"
}


variable "rg_name" {
  description = "Resource Group adı"
  type        = string
  default     = "aks-rg"
}


variable "aks_name" {
  description = "AKS cluster adı"
  type        = string
  default     = "omer-aks-cluster"
}
