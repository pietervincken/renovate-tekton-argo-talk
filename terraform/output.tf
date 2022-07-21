output "external_secrets_client_id" {
  value = azurerm_user_assigned_identity.external_secrets_operator.client_id
}

output "aks_node_rg" {
  value = azurerm_kubernetes_cluster.cluster.node_resource_group
}
