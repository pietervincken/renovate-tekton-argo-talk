output "external_secrets_client_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.client_id
}

output "external_secrets_resource_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.id
}

output "external_dns_client_id" {
  value = azurerm_user_assigned_identity.external_dns_operator.client_id
}

output "external_dns_resource_id" {
  value = azurerm_user_assigned_identity.external_dns_operator.id
}

output "domain" {
  value = azurerm_dns_zone.domain.name
}

output "keyvault" {
  value = azurerm_key_vault.keyvault.name
}

output "rg_runtime" {
  value = azurerm_resource_group.rg.name
}
