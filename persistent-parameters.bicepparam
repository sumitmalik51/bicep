using 'persistent.bicep'

@description('vnet resource prefix')
param vnetresourcePrefix = 'vnet'


@description('virtual Network Name')
param virtualNetworkName  = 'vnetsmuk'


@description('appServices VnetIntegration SubnetName')
param appServicesVnetIntegrationSubnetName  = 'subnetsint' 


@description('db PrivateEndpoints SubnetName')
param dbPrivateEndpointsSubnetName  = 'dbsubnet'


@description('kv PrivateEndpoints SubnetName')
param kvPrivateEndpointsSubnetName  = 'kvsubnet'


@description('virtualNetwork AddressPrefix')
param virtualNetworkAddressPrefix  = '10.0.0.0/16'


@description('appServices VnetIntegrationSubnetPrefix')
param appServicesVnetIntegrationSubnetPrefix  = '10.0.0.0/24' 


@description('db PrivateEndpointsSubnetPrefix')
param dbPrivateEndpointsSubnetPrefix  = '10.0.2.0/24'


@description('kv PrivateEndpointsSubnetPrefix')
param kvPrivateEndpointsSubnetPrefix  = '10.0.1.0/24'

@description('location of the deployment')
param location  = 'uksouth'


@description('name of the resource group for the shared services')
param sharedServicesResourceGroup  = 'shared-services'



@description('dnszone db name')
param dnsZoneDbName  = 'privatelink.mysql.database.azure.com'


@description('dnszone keyvault name')
param dnsZoneKvName  = 'privatelink.vaultcore.azure.net'

@description('resource prefix cms')
param resourcePrefixCms  = 'cmsprefix'


@description('resource prefix website')
param resourcePrefixWebsite  = 'web'

@description('name of the acr')
param acrName  = 'acrnv'

@description('existing name of cummunication service')
param communicationServiceName  = 'emailcms'
