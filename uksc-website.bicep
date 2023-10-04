@description('location')
param location string = resourceGroup().location


@description('tenantId')
param tenantId string = subscription().tenantId


@description('resourcePrefix')
param resourcePrefix string = uniqueString(resourceGroup().id)


@description('appServicePlanId')
param appServicePlanId string


@description('frontDoorId')
param frontDoorId string


@description('cmsHostName')
param cmsHostName string


@description('persistentResourceGroup')
param persistentResourceGroup string


@description('websiteContainerImage')
param websiteContainerImage string


//web app parameters
@description('httpsOnly')
param httpsOnly bool


@description('acrUseManagedIdentityCreds')
param acrUseManagedIdentityCreds bool


@description('alwaysOn')
param alwaysOn bool


@description('detailedErrorLoggingEnabled')
param detailedErrorLoggingEnabled bool


@description('httpLoggingEnabled')
param httpLoggingEnabled bool


@description('requestTracingEnabled')
param requestTracingEnabled bool


@description('ftpsState')
param ftpsState string


@description('http20Enabled')
param http20Enabled bool


// Parameters for KV
@description('enabledForDeployment')
param enabledForTemplateDeployment string


@description('enableRbacAuthorization')
param enableRbacAuthorization bool


@description('enableSoftDelete')
param enableSoftDelete string


@description('publicNetworkAccess')
param publicNetworkAccess string


@description('kvSku')
param kvSku string


@description('kvSkuFamily')
param kvSkuFamily string

@description('enablePurgeProtection for KV')
param enablePurgeProtection bool

param existingManagedIdentitywebsite string


param existingVnet string
resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: existingVnet
  scope: resourceGroup(persistentResourceGroup)
}


resource privateDnsZoneKeyvault 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: 'privatelink.vaultcore.azure.net'
  scope: resourceGroup(persistentResourceGroup)
}


resource managedIdentityWebsite 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: existingManagedIdentitywebsite
  scope: resourceGroup(persistentResourceGroup)
}


module keyVaultWebsite 'modules/key-vault.bicep' = {
  name: 'keyvault-website'
  params: {
    location: location
    resourcePrefix: '${resourcePrefix}-website'
    tenantId: tenantId
    enableRbacAuthorization : enableRbacAuthorization
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableSoftDelete : enableSoftDelete
    publicNetworkAccess:publicNetworkAccess
    kvSku: kvSku
    kvSkuFamily: kvSkuFamily
    principalId: managedIdentityWebsite.properties.principalId
    privateEndpointsSubnetId: vnet.properties.subnets[2].id
    privateDnsZoneId: privateDnsZoneKeyvault.id
    secretsObject: {
      secrets: []
    }
  }
}


module webAppWebsite 'modules/webapp.bicep' = {
  name: 'web-app-uksc-website'
  params: {
    location: location
    resourcePrefix: '${resourcePrefix}-uksc-website'
    appServicePlanId: appServicePlanId
    appContainerImage: websiteContainerImage
     httpsOnly: httpsOnly
    acrUseManagedIdentityCreds: acrUseManagedIdentityCreds
    alwaysOn: alwaysOn
    detailedErrorLoggingEnabled: detailedErrorLoggingEnabled
    httpLoggingEnabled: httpLoggingEnabled
    requestTracingEnabled: requestTracingEnabled
    ftpsState: ftpsState
    http20Enabled: http20Enabled
   
    appSettings: {
      nameValuePairs: [
        { name: 'PORT', value: '3000' }
        { name: 'VAULT_NAME', value: keyVaultWebsite.outputs.name }
        { name: 'STRAPI_HOST', value: cmsHostName }
        { name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS', value: '1' }
        { name: 'MANAGED_IDENTITY_CLIENT_ID', value: managedIdentityWebsite.properties.clientId }
        { name: 'NODE_ENV', value: 'development' }
        { name: 'WEBSITE_PORT', value: '3000' }
        { name: 'WEBSITES_PORT', value: '3000' }
        { name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE', value: 'false' }
        { name: 'WEBSITES_CONTAINER_START_TIME_LIMIT', value: '600' }
      ]
    }
    frontDoorId: frontDoorId
    managedIdentityId: managedIdentityWebsite.id
    managedIdentityClientId: managedIdentityWebsite.properties.clientId
    vnetIntegrationSubnetId: vnet.properties.subnets[0].id
  }
}


module frontDoorEndpointWebsite 'modules/front-door-endpoint.bicep' = {
  name: 'front-door-endpoint-uksc-website'
  params: {
    frontDoorResourceName: '${resourcePrefix}-front-door-profile'
    resourcePrefix: '${resourcePrefix}-uksc-website'
  }
}


module frontDoorOriginMappingWebsite 'modules/front-door-origin-mapping.bicep' = {
  name: 'front-door-origin-mapping-uksc-website'
  dependsOn: [ frontDoorEndpointWebsite ]
  params: {
    hostName: webAppWebsite.outputs.appUrl
    frontDoorResourceName: '${resourcePrefix}-front-door-profile'
    resourcePrefix: '${resourcePrefix}-uksc-website'
    patternsToMatch: [ '/*' ]
    // patternsToMatch: [ '/admin/*', '/api/*' ]
  }
}

