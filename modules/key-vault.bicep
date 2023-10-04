@description('Please update the location for deployment of SQLDB')
param location string
@description('resource prefix')
param resourcePrefix string
@description('Private Endpoint subnetid')
param privateEndpointsSubnetId string
@description('PrivateDNSZone id')
param privateDnsZoneId string
@description('Tenant ID')
param tenantId string
@description('Principal ID for role assignment')
param principalId string
@description('Specifies all secrets {"name":"","value":""} wrapped in a secure object.')
@secure()
param secretsObject object

@description('Template deployment enablment for KV')
param enabledForTemplateDeployment string

@description('Enable Rbac Authorization for KV')
param enableRbacAuthorization bool

@description('Enable enableSoftDelete for KV')
param enableSoftDelete string


@description('Enable publicNetworkAccess for KV')
param publicNetworkAccess string

@description('kvsku for KV')
param kvSku string


@description('kvSkuFamily for KV')
param kvSkuFamily string

@description('enablePurgeProtection for KV')
param enablePurgeProtection bool

// https://learn.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults
// https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-diagnostics
// https://github.com/MicrosoftDocs/azure-docs/issues/52649#issuecomment-648318286
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: '${resourcePrefix}-kv'
  location: location
  properties: {
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    enableSoftDelete: enableSoftDelete

    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: privateEndpointsSubnetId
        }
      ]
    }
    publicNetworkAccess: publicNetworkAccess
    softDeleteRetentionInDays: 7
    sku: {
      name: kvSku
      family: kvSkuFamily
    }
    tenantId: tenantId
  }
}

resource keyVaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-04-01' = {
  name: '${resourcePrefix}-kv-private-endpoint'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${resourcePrefix}-kv-private-endpoint-con'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
        }
      }
    ]
    subnet: {
      id: privateEndpointsSubnetId
    }
    customDnsConfigs: [
      {
        fqdn: '${keyVault.name}.vaultcore.azure.net'
      }
    ]
    customNetworkInterfaceName: '${resourcePrefix}-kv-private-endpoint-nic'
  }
}

resource keyVaultPrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-04-01' = {
  name: '${resourcePrefix}-kv-private-dns-zone'
  parent: keyVaultPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'dnsConfig'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// @description('This is the built-in Key Vault Administrator role. See https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#key-vault-administrator')
resource roleAssignmentMi 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${resourcePrefix}-kv-admin-role-assignment')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// resource roleAssignmentSelf 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid('${resourcePrefix}-role-assignment-self')
//   scope: keyVault
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483')
//     principalId: '401398df-e645-48a9-ac20-27295d890559' //This is the object id of abid in AD, this is required for creating the secrets
//     principalType: 'User'
//   }
// }

resource secrets 'Microsoft.KeyVault/vaults/secrets@2021-04-01-preview' = [for secret in secretsObject.secrets: {
  name: secret.name
  parent: keyVault
  properties: {
    value: secret.value
  }
}]

output name string = keyVault.name
