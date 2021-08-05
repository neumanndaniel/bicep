targetScope = 'subscription'

param name string = ''
param location string = ''
param tags object = {}

var rgName = 'rg-${name}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

output rgName string = resourceGroup.name
output rgId string = resourceGroup.id
