// Parameters
@description('The name of the Azure Container Registry.')
param acr_name string = ''

@description('The resource id of an Azure resource. E.g. AKS cluster, VMSS, etc..')
param resource_id string = ''

@description('The object id of the managed/user-assigned identity of the Azure resource.')
param object_id string = ''

// Resources
resource azure_container_registry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: acr_name
}

resource acr_pull 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  // AcrPull built-in role
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: subscription()
}

resource acr_rbac_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resource_id, azure_container_registry.id, acr_pull.id)
  scope: azure_container_registry
  properties: {
    principalId: object_id
    roleDefinitionId: acr_pull.id
  }
}
