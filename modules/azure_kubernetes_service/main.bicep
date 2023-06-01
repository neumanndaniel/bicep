// Parameters

@description('The name of the Azure Kubernetes Service cluster.')
param name string = ''

@description('The Azure region of the Azure Kubernetes Service cluster.')
param location string = resourceGroup().location

@description('Key:Value tags of the Azure Kubernetes Service cluster.')
param tags object = {}

@description('''
Control naming prefix:
- false (default): aks-name
- true: name
''')
param use_name bool = false

@description('''
The Azure Kubernetes Service cluster and node pool configuration:
- kubernetes_version: The Kubernetes version of the cluster. (1.23.8)
- sla_sku: The SLA SKU tier. (Free|Paid)
- upgrade_channel: The upgrade channel of the cluster. (node-image|none|patch|rapid|stable)
- node_os_upgrade_channel: The upgrade channel of the node image. ('NodeImage'|'None'|'SecurityPatch'|'Unmanaged')
- default_node_pool: The default node pool configuration.
  - availability_zones: Availability zones of the node pool. ([ '1', '2', '3' ])
  - count: Number of nodes in the node pool. (3)
  - enable_auto_scaling: Enable auto-scaling of the node pool. (true|false)
  - max_count: Maximum number of nodes using auto-scaling. (6)
  - min_count: Minimum number of nodes using auto-scaling. (3)
  - mode: The mode of the node pool. (System|User)
  - name: The name of the node pool. (default)
  - node_labels: Kubernetes node labels.
  - node_taints: Kubernetes node taints
  - os_disk_size: The size of the OS disk in GB. (128)
  - vm_size: The size of the virtual machine. (Standard_D2s_v3)
  - workload_runtime: The workload runtime of the node pool. (OCIContainer|WasmWasi)
  - max_surge: The maximum node surge during an upgrade. (2|25%)
  - update_needed_via_agent_pool_api: Updates to the default node pool needed via agent pool API. (true|false)
- additional_node_pools: Additional node pools configuration.
  - availability_zones: Availability zones of the node pool.([ '1', '2', '3' ])
  - count: Number of nodes in the node pool. (3)
  - enable_auto_scaling: Enable auto-scaling of the node pool. (true|false)
  - max_count: Maximum number of nodes using auto-scaling. (6)
  - min_count: Minimum number of nodes using auto-scaling. (3)
  - mode: The mode of the node pool. (System|User)
  - name: The name of the node pool. (default)
  - node_labels: Kubernetes node labels.
  - node_taints: Kubernetes node taints
  - os_disk_size: The size of the OS disk in GB. (128)
  - os_sku: The OS SKU of the node pool. (AzureLinux|Ubuntu)
  - vm_size: The size of the virtual machine. (Standard_D2s_v3)
  - workload_runtime: The workload runtime of the node pool. (OCIContainer|WasmWasi)
  - max_surge: The maximum node surge during an upgrade. (2|25%)
''')
param cluster_configuration object = {
  kubernetes_version: ''
  sla_sku: 'Free'
  upgrade_channel: 'stable'
  node_os_upgrade_channel: 'SecurityPatch'
  default_node_pool: {
    availability_zones: [ '1', '2', '3' ]
    count: 3
    enable_auto_scaling: true
    max_count: 6
    min_count: 3
    mode: 'System'
    name: 'nodepool1'
    node_labels: {}
    node_taints: []
    os_disk_size: 100
    os_sku: 'AzureLinux'
    vm_size: 'Standard_D4s_v3'
    workload_runtime: 'OCIContainer'
    max_surge: '2'
    update_needed_via_agent_pool_api: false
  }
  additional_node_pools: [
    {
      availability_zones: [ '1', '2', '3' ]
      count: 3
      enable_auto_scaling: true
      max_count: 6
      min_count: 3
      mode: 'User'
      name: 'nodepool2'
      node_labels: {}
      node_taints: []
      os_disk_size: 100
      os_sku: 'AzureLinux'
      vm_size: 'Standard_D4s_v3'
      workload_runtime: 'OCIContainer'
      max_surge: 2
    }
  ]
}

@description('''
The Azure Kubernetes Service cluster Azure Container Registry RBAC configuration:
- use_acr: Use Azure Container Registry. (true|false)
- acr_rg: The resource group of the Azure Container Registry.
- acr_name: The name of the Azure Container Registry.
- different_subscription: Use Azure Container Registry in a different subscription. (true|false)
- acr_subscription_id: The subscription ID of the Azure Container Registry.
''')
param acr_configuration object = {
  use_acr: false
  acr_rg: ''
  acr_name: ''
  different_subscription: false
  acr_subscription_id: ''
}

@description('''
The Azure Kubernetes Service cluster access configuration:
- aad_profile_admin_group_object_ids: The AAD group object IDs that will have cluster-admin access to the cluster.
- aad_profile_tenant_id: The AAD tenant ID to use for authentication.
- authorized_ip_ranges: The authorized IP ranges to limit API server access.
''')
param access_configuration object = {
  aad_profile_admin_group_object_ids: []
  aad_profile_tenant_id: ''
  authorized_ip_ranges: []
}

@description('''
The Azure Kubernetes Service cluster add-on configuration:
- azure_policy: Enable Azure Policy for Kubernetes. (true|false)
- azure_monitor: Azure Monitor container insights configuration
  - enabled: Enable Azure Monitor container insigths. (true|false)
  - publish_metrics: Publish Azure Kubernetes Service cluster metrics to Azure Monitor. (true|false)
- microsoft_defender: Enable Microsoft Defender for Containers. (true|false)
- log_analytics_workspace_rg: The resource group of the Log Analytics workspace. Required if azure_monitor.enabled or microsoft_defender is set to true.
- log_analytics_workspace_name: The name of the Log Analytics workspace. Required if azure_monitor.enabled or microsoft_defender is set to true.
''')
param addon_configuration object = {
  azure_policy: false
  azure_monitor: {
    enabled: false
    publish_metrics: false
  }
  microsoft_defender: false
  log_analytics_workspace_rg: ''
  log_analytics_workspace_name: ''
}

@description('''
The Azure Kubernetes Service cluster network configuration:
- vnet_rg: The resource group of the virtual network.
- vnet_name: The name of the virtual network.
- subnet_name: The name of the subnet.
- network_dataplane: The network dataplane to use. (azure|cilium)
- network_plugin: The network plugin to use. (azure|none)
- network_overlay: Enable Azure CNI Overlay (true|false)
- network_policy: The network policy plguin to use. (azure|calico|cilium)
- network_dns_service_ip: The IP address of the Kubernetes DNS service within the Kubernetes service network.
- network_service_cidr: The IP range in CIDR notation of the Kubernetes service network.
- network_pod_cidr: The IP range in CIDR notation of the Kubernetes pod overlay network.
- kube_proxy_mode: The kube-proxy mode. (IPTABLES|IPVS)
''')
param network_configuration object = {
  vnet_rg: ''
  vnet_name: ''
  subnet_name: ''
  network_dataplane: 'azure | cilium'
  network_plugin: 'azure | none'
  network_policy: 'azure | calico | cilium'
  network_dns_service_ip: ''
  network_service_cidr: ''
  network_pod_cidr: ''
  kube_proxy_mode: 'IPTABLES | IPVS'
}

// Variables
var cluster_name = use_name ? name : 'aks-${name}'
var node_rg_name = use_name ? '${cluster_name}-nodes' : 'rg-${cluster_name}-nodes'
var default_node_pool = cluster_configuration.default_node_pool
var all_node_pools = union(array(cluster_configuration.default_node_pool), cluster_configuration.additional_node_pools)

// Existing resources
resource virtual_network_resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: network_configuration.vnet_rg
  scope: subscription()
}

resource virtual_network 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: network_configuration.vnet_name
  scope: virtual_network_resource_group
}

resource subnet_id 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  name: network_configuration.subnet_name
  parent: virtual_network
}

resource log_analytics_network_resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' existing = if (addon_configuration.azure_monitor.enabled || addon_configuration.microsoft_defender.enabled) {
  name: addon_configuration.log_analytics_workspace_rg
  scope: subscription()
}

resource log_analytics_workspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = if (addon_configuration.azure_monitor.enabled || addon_configuration.microsoft_defender.enabled) {
  name: addon_configuration.log_analytics_workspace_name
  scope: log_analytics_network_resource_group
}

resource monitoring_metrics_publisher 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = if (addon_configuration.azure_monitor.enabled && addon_configuration.azure_monitor.publish_metrics) {
  // Monitoring Metrics Publisher built-in role
  name: '3913510d-42f4-4e42-8a64-420c390055eb'
  scope: subscription()
}

module data_azure_kubernetes_service_default_node_pool '../data_azure_kubernetes_service_node_pool/main.bicep' = if (default_node_pool.update_needed_via_agent_pool_api) {
  scope: resourceGroup()
  name: 'data-${cluster_name}-${default_node_pool.name}'
  params: {
    cluster_name: cluster_name
    node_pool_name: default_node_pool.name
  }
}

// Resources
resource azure_kubernetes_service 'Microsoft.ContainerService/managedClusters@2023-03-02-preview' = {
  name: cluster_name
  location: location
  tags: tags
  sku: {
    name: 'Base'
    tier: cluster_configuration.sla_sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    aadProfile: {
      adminGroupObjectIDs: access_configuration.aad_profile_admin_group_object_ids
      enableAzureRBAC: true
      managed: true
      tenantID: access_configuration.aad_profile_tenant_id
    }
    addonProfiles: {
      azurepolicy: {
        enabled: addon_configuration.azure_policy
      }
      kubeDashboard: {
        enabled: false
      }
      omsagent: {
        enabled: addon_configuration.azure_monitor.enabled
        config: {
          logAnalyticsWorkspaceResourceID: addon_configuration.azure_monitor.enabled ? log_analytics_workspace.id : null
        }
      }
    }
    agentPoolProfiles: [
      {
        availabilityZones: default_node_pool.availability_zones
        count: default_node_pool.count
        enableAutoScaling: default_node_pool.enable_auto_scaling
        kubeletDiskType: 'OS'
        maxCount: default_node_pool.enable_auto_scaling ? default_node_pool.max_count : null
        maxPods: 250
        minCount: default_node_pool.enable_auto_scaling ? default_node_pool.min_count : null
        mode: default_node_pool.mode
        name: (length(default_node_pool.name) <= 12 ? default_node_pool.name : substring(default_node_pool.name, 0, 12))
        nodeLabels: default_node_pool.node_labels
        nodeTaints: default_node_pool.node_taints
        orchestratorVersion: cluster_configuration.kubernetes_version
        osDiskSizeGB: default_node_pool.os_disk_size
        osDiskType: 'Ephemeral'
        osSKU: default_node_pool.os_sku
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        upgradeSettings: {
          maxSurge: default_node_pool.update_needed_via_agent_pool_api ? data_azure_kubernetes_service_default_node_pool.outputs.max_surge : default_node_pool.max_surge
        }
        vmSize: default_node_pool.vm_size
        vnetSubnetID: subnet_id.id
        workloadRuntime: default_node_pool.workload_runtime
      }
    ]
    apiServerAccessProfile: {
      authorizedIPRanges: access_configuration.authorized_ip_ranges
    }
    autoUpgradeProfile: {
      upgradeChannel: cluster_configuration.upgrade_channel
      nodeOSUpgradeChannel: cluster_configuration.node_os_upgrade_channel
    }
    disableLocalAccounts: true
    dnsPrefix: cluster_name
    enableRBAC: true
    kubernetesVersion: cluster_configuration.kubernetes_version
    networkProfile: {
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
      loadBalancerProfile: {
        idleTimeoutInMinutes: 4
        managedOutboundIPs: {
          count: 1
        }
      }
      networkDataplane: toLower(network_configuration.network_plugin) != 'none' ? network_configuration.network_dataplane : null
      networkPlugin: network_configuration.network_plugin
      networkPluginMode: toLower(network_configuration.network_plugin) != 'none' && network_configuration.network_overlay ? 'Overlay' : null
      networkPolicy: toLower(network_configuration.network_plugin) != 'none' ? network_configuration.network_policy : null
      dnsServiceIP: toLower(network_configuration.network_plugin) != 'none' ? network_configuration.network_dns_service_ip : null
      podCidr: toLower(network_configuration.network_plugin) != 'none' && network_configuration.network_overlay ? network_configuration.network_pod_cidr : null
      serviceCidr: toLower(network_configuration.network_plugin) != 'none' ? network_configuration.network_service_cidr : null
      kubeProxyConfig: {
        enabled: toLower(network_configuration.network_plugin) != 'none' ? true : false
        mode: network_configuration.kube_proxy_mode
      }
    }
    nodeResourceGroup: node_rg_name
    publicNetworkAccess: 'Enabled'
    securityProfile: {
      defender: {
        logAnalyticsWorkspaceResourceId: addon_configuration.microsoft_defender ? log_analytics_workspace.id : null
        securityMonitoring: {
          enabled: addon_configuration.microsoft_defender
        }
      }
    }
    storageProfile: {
      blobCSIDriver: {
        enabled: true
      }
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
  }
}

resource azure_kubernetes_service_node_pools 'Microsoft.ContainerService/managedClusters/agentPools@2023-03-02-preview' = [for node_pool in all_node_pools: {
  name: length(node_pool.name) <= 12 ? node_pool.name : substring(node_pool.name, 0, 12)
  parent: azure_kubernetes_service
  properties: {
    availabilityZones: node_pool.availability_zones
    count: node_pool.count
    enableAutoScaling: node_pool.enable_auto_scaling
    kubeletDiskType: 'OS'
    maxCount: node_pool.enable_auto_scaling ? node_pool.max_count : null
    maxPods: 250
    minCount: node_pool.enable_auto_scaling ? node_pool.min_count : null
    mode: node_pool.mode
    nodeLabels: node_pool.node_labels
    nodeTaints: node_pool.node_taints
    orchestratorVersion: cluster_configuration.kubernetes_version
    osDiskSizeGB: node_pool.os_disk_size
    osDiskType: 'Ephemeral'
    osSKU: node_pool.os_sku
    osType: 'Linux'
    type: 'VirtualMachineScaleSets'
    upgradeSettings: {
      maxSurge: node_pool.max_surge
    }
    vmSize: node_pool.vm_size
    vnetSubnetID: subnet_id.id
    workloadRuntime: node_pool.workload_runtime
  }
}]

resource aks_rbac_assignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (addon_configuration.azure_monitor.enabled && addon_configuration.azure_monitor.publish_metrics) {
  name: guid(azure_kubernetes_service.id, monitoring_metrics_publisher.id)
  scope: azure_kubernetes_service
  properties: {
    principalId: azure_kubernetes_service.properties.addonProfiles.omsagent.identity.objectId
    roleDefinitionId: monitoring_metrics_publisher.id
  }
}

module rbac_vnet_subnet '../rbac_vnet_subnet/main.bicep' = {
  scope: resourceGroup(network_configuration.vnet_rg)
  name: '${cluster_name}-rbac-vnet-subnet'
  params: {
    vnet_name: network_configuration.vnet_name
    subnet_name: network_configuration.subnet_name
    resource_id: azure_kubernetes_service.id
    object_id: azure_kubernetes_service.identity.principalId
  }
}

module rbac_azure_container_registry '../rbac_container_registry/main.bicep' = if (acr_configuration.use_acr && !acr_configuration.different_subscription) {
  scope: resourceGroup(acr_configuration.acr_rg)
  name: '${cluster_name}-rbac-container-registry'
  params: {
    acr_name: acr_configuration.acr_name
    resource_id: azure_kubernetes_service.id
    object_id: azure_kubernetes_service.properties.identityProfile.kubeletidentity.objectId
  }
}

module rbac_subscription_azure_container_registry '../rbac_subscription_container_registry/main.bicep' = if (acr_configuration.use_acr && acr_configuration.different_subscription) {
  scope: subscription(acr_configuration.acr_subscription_id)
  name: '${cluster_name}-rbac-subscription-container-registry'
  params: {
    acr_name: acr_configuration.acr_name
    acr_rg: acr_configuration.acr_rg
    resource_name: cluster_name
    resource_id: azure_kubernetes_service.id
    object_id: azure_kubernetes_service.properties.identityProfile.kubeletidentity.objectId
  }
}

output aks_id string = azure_kubernetes_service.id
output aks_name string = azure_kubernetes_service.name
output aks_acr_role_assignment_id string = acr_configuration.use_acr && !acr_configuration.different_subscription ? rbac_azure_container_registry.outputs.acr_role_assignment_id : acr_configuration.use_acr && acr_configuration.different_subscription ? rbac_subscription_azure_container_registry.outputs.acr_role_assignment_id : null
output aks_acr_role_assignment_api_version string = acr_configuration.use_acr && !acr_configuration.different_subscription ? rbac_azure_container_registry.outputs.acr_role_assignment_api_version : acr_configuration.use_acr && acr_configuration.different_subscription ? rbac_subscription_azure_container_registry.outputs.acr_role_assignment_api_version : null
output aks_snet_role_assignment_id string = rbac_vnet_subnet.outputs.snet_role_assignment_id
output aks_snet_role_assignment_api_version string = rbac_vnet_subnet.outputs.snet_role_assignment_api_version
