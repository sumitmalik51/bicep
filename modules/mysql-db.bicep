@description('Update the location for deployment of SQLDB')
param location string

@description('Unique String')
param resourcePrefix string

@description('Database Name for SQLDB')
param databaseName string = '${resourcePrefix}-database'

@description('Database Password for SQLDB')
@secure()
param databaseUser string

@description('Database Password for SQLDB')
@secure()
param databasePassword string

@description('Subnet ID of Private Endpoint for SQLDB')
param privateEndpointsSubnetId string

@description('Private DNS zone ID for SQLDB')
param dnsZoneId string

@description('Please update SKU for SqlDB')
param sqlDbSku string

@description('Please update Tier for SqlDB')
param sqlDbTier string

// For complete configuration visit
// https://learn.microsoft.com/en-us/azure/templates/microsoft.dbformysql/flexibleservers?pivots=deployment-language-bicep
// https://github.com/Azure/azure-quickstart-templates/tree/master/quickstarts/microsoft.dbformysql/flexible-mysql-with-vnet
// https://learn.microsoft.com/en-us/azure/mysql/flexible-server/quickstart-create-bicep
resource mySqlDatabaseServer 'Microsoft.DBforMySQL/flexibleServers@2022-09-30-preview' = {
  name: '${resourcePrefix}-mysql-server'
  location: location
  sku: {
    name: sqlDbSku
    tier: sqlDbTier
  }
  properties: {
    administratorLogin: databaseUser
    administratorLoginPassword: databasePassword
    createMode: 'Default'
    version: '8.0.21'
    network: {
      delegatedSubnetResourceId: privateEndpointsSubnetId
      privateDnsZoneResourceId: dnsZoneId
      publicNetworkAccess: 'Disabled'
    }
  }

  resource mySqlDatabase 'databases@2022-01-01' = {
    name: databaseName
    properties: {
      charset: 'utf8'
      collation: 'utf8_general_ci'
    }
  }

  // resource firewallRuleAllowAzureIPs 'firewallRules@2022-01-01' = {
  //   name: 'AllowAzureIPs'
  //   properties: {
  //     startIpAddress: '0.0.0.0'
  //     endIpAddress: '255.255.255.255'
  //   }
  // }
}

output databaseServerName string = mySqlDatabaseServer.name
output databaseName string = databaseName
output databaseHostName string = mySqlDatabaseServer.properties.fullyQualifiedDomainName
