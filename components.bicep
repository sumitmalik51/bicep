@description('Location')
param location string

@description('Resource prefix')
param resourcePrefix string = uniqueString(resourceGroup().id)


// Parameters for App Service Plan
@description('Update SKU for App Service Plan')
param aspSku string


@description('Update Tier for App Service Plan')
param aspTier string


@description('Update kind for App Service Plan it can be Windows or Linux')
param aspKind string


//Parameters for Front Door
@description('Update SKU for FrontDoor')
param frontDoorSku string


//parameters for CMS Modules


// Parameters for KV
@description('enableForTemplateDeployment')
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

// Parameters for existing resources
@description('existingVnet')
param existingVnet string


@description('existingPrivateDnsZoneKeyvault')
param existingPrivateDnsZoneKeyvault string


@description('existingPrivateDnsZoneDb')
param existingPrivateDnsZoneDb string


@description('existingManagedIdentityCms')
param existingManagedIdentityCms string

//parameters for UKSC Website Modules
@description('persistentResourceGroup')
param persistentResourceGroup string


@description('websiteContainerImage')
param websiteContainerImage string

@description('acrUseManagedIdentityCreds')
param acrUseManagedIdentityCreds bool

@description('alwaysOn')
param alwaysOn bool

@description('cmsContainerImage')
param cmsContainerImage string

@description('databaseName')
param databaseName string

@description('databasePassword')
param databasePassword string

@description('databaseUser')
param databaseUser string

@description('detailedErrorLoggingEnabled')
param detailedErrorLoggingEnabled bool

@description('ftpsState')
param ftpsState string

@description('http20Enabled')
param http20Enabled bool

@description('httpLoggingEnabled')
param httpLoggingEnabled bool

@description('httpsOnly')
param httpsOnly bool

@description('requestTracingEnabled')
param requestTracingEnabled bool

@description('sqlDbSku')
param sqlDbSku string

@description('sqlDbTier')
param sqlDbTier string

@description('tenantId')
param tenantId string

@description('db PrivateEndpoints SubnetName')
param dbPrivateEndpointsSubnetName string


@description('kv PrivateEndpoints SubnetName')
param kvPrivateEndpointsSubnetName string


@description('managed identity for Website app')
param existingManagedIdentitywebsite  string

module appServicePlan './modules/app-service-plan.bicep' = {
  name: 'app-service-plan'
  params: {
    location: location
    resourcePrefix: resourcePrefix
    aspSku : aspSku
    aspTier : aspTier
    aspKind : aspKind
  }
}


module frontDoor './modules/front-door.bicep' = {
  name: 'front-door'
  params: {
    resourcePrefix: resourcePrefix
    frontDoorSku : frontDoorSku
  }
}


module cmsComponents 'cms.bicep' = {
  name: 'cms-components'
  dependsOn: [ appServicePlan, frontDoor ]
  params: {
    location: location
    appServicePlanId: appServicePlan.outputs.id
    frontDoorId: frontDoor.outputs.id
    enabledForTemplateDeployment:enabledForTemplateDeployment
    enableRbacAuthorization:enableRbacAuthorization
    enablePurgeProtection: enablePurgeProtection
    enableSoftDelete:enableSoftDelete
    publicNetworkAccess:publicNetworkAccess
    kvSku:kvSku
    kvSkuFamily:kvSkuFamily
    existingManagedIdentityCms:existingManagedIdentityCms
    existingPrivateDnsZoneKeyvault:existingPrivateDnsZoneKeyvault
    existingPrivateDnsZoneDb:existingPrivateDnsZoneDb
    existingVnet:existingVnet
    acrUseManagedIdentityCreds:acrUseManagedIdentityCreds
    alwaysOn: alwaysOn
    cmsContainerImage: cmsContainerImage
    databaseName: databaseName
    databasePassword: databasePassword
    databaseUser: databaseUser
    detailedErrorLoggingEnabled: detailedErrorLoggingEnabled
    ftpsState: ftpsState
    http20Enabled: http20Enabled
    httpLoggingEnabled: httpLoggingEnabled
    httpsOnly: httpsOnly
    persistentResourceGroup: persistentResourceGroup
    requestTracingEnabled: requestTracingEnabled
    resourcePrefix: resourcePrefix
    sqlDbSku: sqlDbSku
    sqlDbTier: sqlDbTier
    tenantId: tenantId
    dbPrivateEndpointsSubnetName: dbPrivateEndpointsSubnetName
    kvPrivateEndpointsSubnetName: kvPrivateEndpointsSubnetName
  }
}

module ukscWebsiteComponents './uksc-website.bicep' = {
  name: 'uksc-website-components'
  dependsOn: [ cmsComponents ]
  params: {
    location: location
    websiteContainerImage: websiteContainerImage
    persistentResourceGroup: persistentResourceGroup
    enabledForTemplateDeployment:enabledForTemplateDeployment
    enableRbacAuthorization:enableRbacAuthorization
    enableSoftDelete:enableSoftDelete
    publicNetworkAccess:publicNetworkAccess
    kvSku:kvSku
    kvSkuFamily:kvSkuFamily
    appServicePlanId: appServicePlan.outputs.id
    frontDoorId: frontDoor.outputs.id
    cmsHostName: cmsComponents.outputs.cmsHostName
    acrUseManagedIdentityCreds:acrUseManagedIdentityCreds
    alwaysOn:alwaysOn
    detailedErrorLoggingEnabled:detailedErrorLoggingEnabled
    enablePurgeProtection:enablePurgeProtection
    ftpsState:ftpsState
    http20Enabled:http20Enabled
    httpLoggingEnabled:httpLoggingEnabled
    httpsOnly:httpsOnly
    requestTracingEnabled:requestTracingEnabled
    existingVnet:existingVnet
    existingManagedIdentitywebsite: existingManagedIdentitywebsite
  }
}





