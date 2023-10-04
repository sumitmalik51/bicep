@description('location')
param location string


@description('resourcePrefix')
param resourcePrefix string


@description('Id of App service plan to use')
param appServicePlanId string


@description('Managed identity for authentication')
param managedIdentityId string


@description('Client id of managed identity')
param managedIdentityClientId string


@description('container image to use in app')
param appContainerImage string


@description('Subnet id for vnet integration')
param vnetIntegrationSubnetId string


@description('Id of frontdoor')
param frontDoorId string


@description('appSettings')
@secure()
param appSettings object


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


resource appServiceWebApp 'Microsoft.Web/sites@2021-02-01' = {
  name: '${resourcePrefix}-webapp'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
  properties: {
    httpsOnly: httpsOnly
    //https://learn.microsoft.com/en-gb/azure/app-service/app-service-key-vault-references
    keyVaultReferenceIdentity: managedIdentityId
    serverFarmId: appServicePlanId
    siteConfig: {
      acrUseManagedIdentityCreds: acrUseManagedIdentityCreds
      acrUserManagedIdentityID: managedIdentityClientId
      alwaysOn: alwaysOn
      appSettings: appSettings.nameValuePairs
      detailedErrorLoggingEnabled: detailedErrorLoggingEnabled
      httpLoggingEnabled: httpLoggingEnabled
      requestTracingEnabled: requestTracingEnabled
      ftpsState: ftpsState
      http20Enabled: http20Enabled
      keyVaultReferenceIdentity: managedIdentityId
      linuxFxVersion: 'DOCKER|${appContainerImage}'
      minTlsVersion: '1.2'
      ipSecurityRestrictions: [
        {
          tag: 'ServiceTag'
          ipAddress: 'AzureFrontDoor.Backend'
          action: 'Allow'
          priority: 100
          headers: {
            'x-azure-fdid': [
              frontDoorId
            ]
          }
          name: 'Allow traffic from Front Door'
        }
      ]
      vnetRouteAllEnabled: true
    }
    virtualNetworkSubnetId: vnetIntegrationSubnetId
  }
}


output appUrl string = appServiceWebApp.properties.defaultHostName



