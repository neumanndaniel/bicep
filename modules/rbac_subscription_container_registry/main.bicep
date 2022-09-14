targetScope = 'subscription'

// Parameters
@description('The name of the Azure Container Registry.')
param acr_name string = ''

@description('The resource group name of the Azure Container Registry.')
param acr_rg string = ''

@description('The resource name of an Azure resource. E.g. AKS cluster, VMSS, etc..')
param resource_name string = ''

@description('The resource id of an Azure resource. E.g. AKS cluster, VMSS, etc..')
param resource_id string = ''

@description('The object id of the managed/user-assigned identity of the Azure resource.')
param object_id string = ''

// Resources
resource acr_resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: acr_rg
  scope: subscription()
}

module rbac_azure_container_registry '../rbac_container_registry/main.bicep' = {
  scope: acr_resource_group
  name: '${resource_name}-rbac-container-registry'
  params: {
    acr_name: acr_name
    resource_id: resource_id
    object_id: object_id
  }
}
