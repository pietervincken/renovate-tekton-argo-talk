output "external_secrets_client_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.client_id
}

output "external_secrets_resource_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.id
}
