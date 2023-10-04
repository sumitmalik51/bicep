@description('Please update the location for deployment of App Service Plan')
param location string

@description('Unique String')
param resourcePrefix string

@description('Please update SKU for App Service Plan')
param aspSku string

@description('Please update Tier for App Service Plan')
param aspTier string

@description('Please update kind for App Service Plan it can be Windows or Linux')
param aspKind string 


resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${resourcePrefix}-app-service-plan'
  location: location
  sku: {
    name: aspSku
    tier: aspTier
  }
  kind: aspKind
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
