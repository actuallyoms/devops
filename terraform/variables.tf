variable "rg_name" {
  description = "Resource Group name"
  type        = string
  default     = "tf-test-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "westeurope"
}
