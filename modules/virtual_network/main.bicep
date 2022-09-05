// Parameters
@description('The name of the virtual network and subnet.')
param name string = ''

@description('The azure region of the virtual network.')
param location string = resourceGroup().location

@description('Key:Value tags of the resource group.')
param tags object = {}

@description('The address prefixes in CIDR notation of the virtual network.')
param address_prefixes array = []

@description('The custom DNS servers of the virtual network.')
param dns_servers array = []

@description('The address prefix in CIDR notation of the subnet.')
param subnet_address_prefix string = ''

@description('''
Control the naming prefix:
- false (default): vnet-name / snet-name
- true: name
''')
param use_name bool = false

// Variables
var vnet_name = (!use_name) ? 'vnet-${name}' : name
var snet_name = (!use_name) ? 'snet-${name}' : name

// Resources
resource virtual_network 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: vnet_name
  location: location
  tags: tags

  properties: {
    addressSpace: {
      addressPrefixes: address_prefixes
    }
    dhcpOptions: {
      dnsServers: dns_servers
    }
    subnets: [
      {
        name: snet_name
        properties: {
          addressPrefix: subnet_address_prefix
        }
      }
    ]
  }
}

// Outputs
output vnet_rg string = resourceGroup().name
output vnet_name string = virtual_network.name
output subnet_name string = virtual_network.properties.subnets[0].name
output vnet_id string = virtual_network.id
output subnet_id string = virtual_network.properties.subnets[0].id
