// Parameters
@description('The name of the Azure Kubernetes Service cluster.')
param cluster_name string = ''

@description('The name of the Azure Kubernetes Service cluster node pool.')
param node_pool_name string = ''

// Resources
resource azure_kubernetes_service_node_pool 'Microsoft.ContainerService/managedClusters/agentPools@2023-03-02-preview' existing = {
  name: '${cluster_name}/${node_pool_name}'
}

// Outputs
output max_surge string = azure_kubernetes_service_node_pool.properties.upgradeSettings.maxSurge
