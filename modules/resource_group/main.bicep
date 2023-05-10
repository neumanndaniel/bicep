targetScope = 'subscription'

// Parameters
@description('The name of the resource group.')
param name string = ''

@description('The Azure region of the resource group.')
param location string = ''

@description('Key:Value tags of the resource group.')
param tags object = {}

@description('''
Control naming prefix:
- false (default): rg-name
- true: name
''')
param use_name bool = false

// Variables
var rg_name = use_name ? name : 'rg-${name}'

// Resources
resource resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rg_name
  location: location
  tags: tags
}

// Outputs
output rg_name string = resource_group.name
output rg_location string = resource_group.location
output rg_id string = resource_group.id
