// Parameters
@description('The name of the virtual network.')
param vnet_name string = ''

@description('The name of the subnet.')
param subnet_name string = ''

@description('The resource id of an Azure resource. E.g. AKS cluster, VMSS, etc..')
param resource_id string = ''

@description('The object id of the managed/user-assigned identity of the Azure resource.')
param object_id string = ''

// Resources
resource virtual_network 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: vnet_name
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: subnet_name
  parent: virtual_network
}

resource network_contributor 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  // Network Contributor built-in role
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  scope: subscription()
}

resource subnet_rbac_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resource_id, virtual_network.id, subnet.id, network_contributor.id)
  scope: subnet
  properties: {
    principalId: object_id
    roleDefinitionId: network_contributor.id
  }
}

output snet_role_assignment_id string = subnet_rbac_assignment.id
output snet_role_assignment_api_version string = subnet_rbac_assignment.apiVersion
