// Common Parameters
@description('The location of the resources.')
param location string


@description('The tenant ID of the Azure AD tenant used for authentication.')
param tenantId string


@description('The prefix to use for all resources.')
param resourcePrefix string


@description('The name of the resource group to deploy to.')
param persistentResourceGroup string



@description('container image to use')
param cmsContainerImage string


@description('Id of App service plan to use')
param appServicePlanId string


@description('Id of frontdoor')
param frontDoorId string

// Parameters for SQLDB
@description('Sku for SqlDb')
param sqlDbSku string


@description('Tier for SqlDB')
param sqlDbTier string


@description('Name of database')
param databaseName string


@description('database user for SqlDB')
param databaseUser string


@description('password for SqlDB')
@secure()
param databasePassword string


// Parameters for KV
@description('enabledForDeployment')
param enabledForTemplateDeployment string


@description('enable RbacAuthorization')
param enableRbacAuthorization bool


@description('enable SoftDelete')
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


// Existing resources
resource vnet 'Microsoft.Network/virtualNetworks@2019-11-01' existing = {
  name: existingVnet
  scope: resourceGroup(persistentResourceGroup)
}
resource privateDnsZoneKeyvault 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: existingPrivateDnsZoneKeyvault
  scope: resourceGroup(persistentResourceGroup)
}


resource privateDnsZoneDb 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: existingPrivateDnsZoneDb
  scope: resourceGroup(persistentResourceGroup)
}


resource managedIdentityCms 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: existingManagedIdentityCms
  scope: resourceGroup(persistentResourceGroup)
}


// MySQL Database Server module
module mysqlDatabaseServer 'modules/mysql-db.bicep' = {
  name: 'mysql-database'
  dependsOn: [keyVaultCms]
  params: {
    location: location
    resourcePrefix: resourcePrefix
    databaseUser: keyVaultCmsRef.getSecret('dbuser')
    databasePassword: keyVaultCmsRef.getSecret('dbpassword')
    privateEndpointsSubnetId: vnet.properties.subnets[1].id
    dnsZoneId: privateDnsZoneDb.id
    sqlDbSku: sqlDbSku
    sqlDbTier: sqlDbTier
  }
}


// Key Vault module
module keyVaultCms 'modules/key-vault.bicep' = {
  name: 'keyvault-cms'
  params: {
    location: location
    resourcePrefix: '${resourcePrefix}-cms'
    tenantId: tenantId
    principalId: managedIdentityCms.properties.principalId
    privateEndpointsSubnetId: vnet.properties.subnets[2].id
    privateDnsZoneId: privateDnsZoneKeyvault.id
    enableRbacAuthorization : enableRbacAuthorization
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enablePurgeProtection: enablePurgeProtection
    enableSoftDelete : enableSoftDelete
    publicNetworkAccess:publicNetworkAccess
    kvSku: kvSku
    kvSkuFamily: kvSkuFamily
    secretsObject: {
      secrets: [
        { name: 'dbuser', value: resourcePrefix }
        { name: 'dbpassword', value: base64(guid('${resourcePrefix}-password')) } // use random string generator
        { name: 'appKeys', value: base64(guid('${resourcePrefix}-appKeys')) }
        { name: 'jwtSecret', value: base64(guid('${resourcePrefix}-jwtSecret')) }
        { name: 'adminJwtSecret', value: base64(guid('${resourcePrefix}-adminJwtSecret')) }
        { name: 'adminApiTokenSalt', value: base64(guid('${resourcePrefix}-adminApiTokenSalt')) }
        { name: 'adminTransferTokenSalt', value: base64(guid('${resourcePrefix}-adminTransferTokenSalt')) }
      ]
    }
  }
}


// Key Vault reference
resource keyVaultCmsRef 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultCms.outputs.name
}


// Web App module
module webAppCms 'modules/webapp.bicep' = {
  name: 'web-app-cms'
  params: {
    location: location
    resourcePrefix: '${resourcePrefix}-cms'
    appServicePlanId: appServicePlanId
    appContainerImage: cmsContainerImage
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
        { name: 'APP_KEYS', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=appKeys)' }
        { name: 'API_TOKEN_SALT', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=adminApiTokenSalt)' }
        { name: 'ADMIN_JWT_SECRET', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=adminJwtSecret)' }
        { name: 'CMS_PUBLIC_URL', value: 'https://${frontDoorEndpointCms.outputs.endpointHostName}' }
        { name: 'TRANSFER_TOKEN_SALT', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=adminTransferTokenSalt)' }
        { name: 'JWT_SECRET', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=jwtSecret)' }
        { name: 'DATABASE_CLIENT', value: 'mysql2' }
        { name: 'DATABASE_HOST', value: mysqlDatabaseServer.outputs.databaseHostName }
        { name: 'DATABASE_NAME', value: databaseName }
        { name: 'DATABASE_PORT', value: '3306' }
        { name: 'DATABASE_SSL', value: 'true' }
        { name: 'DATABASE_USERNAME', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=dbuser)' }
        { name: 'DATABASE_PASSWORD', value: '@Microsoft.KeyVault(VaultName=${keyVaultCms.outputs.name};SecretName=dbpassword)' }
        { name: 'MANAGED_IDENTITY_CLIENT_ID', value: managedIdentityCms.properties.clientId }
        { name: 'NODE_ENV', value: 'development' }
        { name: 'PORT', value: '1337' }
        { name: 'WEBSITE_HTTPLOGGING_RETENTION_DAYS', value: '1' }
        { name: 'WEBSITE_PORT', value: '1337' }
        { name: 'WEBSITES_PORT', value: '1337' }
        { name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE', value: 'false' }
        { name: 'WEBSITES_CONTAINER_START_TIME_LIMIT', value: '600' }
        { name: 'EMAIL_PROVIDER_AZ_COMM_SERVICE_RESOURCE_NAME', value: 'uksc-communication-service' }
        { name: 'EMAIL_PROVIDER_DEFAULT_FROM', value: 'DoNotReply@20555824-6903-44c0-99ef-606ac60be394.azurecomm.net' }
        { name: 'EMAIL_PROVIDER_DEFAULT_REPLY_TO', value: 'DoNotReply@20555824-6903-44c0-99ef-606ac60be394.azurecomm.net' }
      ]
    }


    frontDoorId: frontDoorId
    managedIdentityId: managedIdentityCms.id
    managedIdentityClientId: managedIdentityCms.properties.clientId
    vnetIntegrationSubnetId: vnet.properties.subnets[0].id
  }
}


// Front Door Endpoint module
module frontDoorEndpointCms 'modules/front-door-endpoint.bicep' = {
  name: 'front-door-endpoint-cms'
  params: {
    frontDoorResourceName: '${resourcePrefix}-front-door-profile'
    resourcePrefix: '${resourcePrefix}-cms'
  }
}


// Front Door Origin Mapping module
module frontDoorOriginMappingCms 'modules/front-door-origin-mapping.bicep' = {
  name: 'front-door-origin-mapping-cms'
  dependsOn: [
    frontDoorEndpointCms
  ]
  params: {
    hostName: webAppCms.outputs.appUrl
    frontDoorResourceName: '${resourcePrefix}-front-door-profile'
    resourcePrefix: '${resourcePrefix}-cms'
    patternsToMatch: [ '/*' ]
    // patternsToMatch: [ '/admin/*', '/api/*' ]
  }
}


// Output
output cmsHostName string = frontDoorEndpointCms.outputs.endpointHostName
