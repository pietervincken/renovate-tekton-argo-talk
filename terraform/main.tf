# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.13.0"
    }
  }
  backend "azurerm" {}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Configure the Azure Active Directory Provider
provider "azuread" {
}

locals {

  email = "pieter.vincken@ordina.be"
  name  = "renovate-talk"

  common_tags = {
    created-by = local.email
    project    = local.name
  }

  location = "West Europe"
  rg       = "rg-${local.name}"

  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  upn           = "${replace(local.email, "@", "_")}#EXT#@${local.tenant_domain}"
}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg
  location = local.location
}

resource "azurerm_kubernetes_cluster" "cluster" {
  name                = "${local.name}-k8s"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.name
  kubernetes_version  = "1.23.5"


  default_node_pool {
    zones               = [3]
    node_count          = 3
    enable_auto_scaling = false
    vm_size             = "standard_b2s"
    name                = "default"
    os_sku              = "Ubuntu"
  }

  azure_active_directory_role_based_access_control {
    managed = true
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

data "azuread_user" "user" {
  user_principal_name = local.upn
}

data "azuread_domains" "aad_domains" {

}

resource "azurerm_role_assignment" "aks" {
  scope                = azurerm_kubernetes_cluster.cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = data.azuread_user.user.object_id
}

resource "azurerm_key_vault" "keyvault" {
  name                = "kv${local.name}"
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_subscription.current.tenant_id
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_key_vault_access_policy" "myaccess" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = azurerm_key_vault.keyvault.tenant_id
  object_id    = data.azuread_user.user.object_id

  secret_permissions = [
    "Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"
  ]
}

resource "azurerm_user_assigned_identity" "external_secrets_operator" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = "external-secrets-operator"
}

resource "azurerm_key_vault_access_policy" "external_secrets_operator" {
  key_vault_id = azurerm_key_vault.keyvault.id
  tenant_id    = azurerm_key_vault.keyvault.tenant_id
  object_id    = azurerm_user_assigned_identity.external_secrets_operator.principal_id

  secret_permissions = [
    "Get", "List"
  ]

  key_permissions = [
    "Decrypt", "Encrypt", "Get", "List", "UnwrapKey", "Verify", "WrapKey"
  ]

  certificate_permissions = [
    "Get", "List"
  ]

}

# resource "azurerm_key_vault_secret" "mysecret" {
#   name         = "mysecret"
#   key_vault_id = azurerm_key_vault.keyvault.id
#   value        = "hello-world"

#   depends_on = [
#     azurerm_key_vault_access_policy.myaccess
#   ]
# }
