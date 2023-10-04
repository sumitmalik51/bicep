@description('vnet resource prefix')
param vnetresourcePrefix string


@description('virtual Network Name')
param virtualNetworkName string


@description('appServices VnetIntegration SubnetName')
param appServicesVnetIntegrationSubnetName string


@description('db PrivateEndpoints SubnetName')
param dbPrivateEndpointsSubnetName string


@description('kv PrivateEndpoints SubnetName')
param kvPrivateEndpointsSubnetName string


@description('virtualNetwork AddressPrefix')
param virtualNetworkAddressPrefix string


@description('appServices VnetIntegrationSubnetPrefix')
param appServicesVnetIntegrationSubnetPrefix string


@description('db PrivateEndpointsSubnetPrefix')
param dbPrivateEndpointsSubnetPrefix string


@description('kv PrivateEndpointsSubnetPrefix')
param kvPrivateEndpointsSubnetPrefix string

@description('location of the deployment')
param location string = resourceGroup().location


@description('name of the resource group for the shared services')
param sharedServicesResourceGroup string = 'shared-services'


@description('name of the vnet')
param vnetName string


@description('dnszone db name')
param dnsZoneDbName string


@description('dnszone keyvault name')
param dnsZoneKvName string

@description('resource prefix cms')
param resourcePrefixCms string


@description('resource prefix website')
param resourcePrefixWebsite string

module vnet 'modules/vnet.bicep' = {
  name: vnetName
  params: {
    location: location
    vnetresourcePrefix: vnetresourcePrefix
    virtualNetworkName: virtualNetworkName
    appServicesVnetIntegrationSubnetName: appServicesVnetIntegrationSubnetName
    dbPrivateEndpointsSubnetName: dbPrivateEndpointsSubnetName
    kvPrivateEndpointsSubnetName: kvPrivateEndpointsSubnetName
    virtualNetworkAddressPrefix: virtualNetworkAddressPrefix
    appServicesVnetIntegrationSubnetPrefix: appServicesVnetIntegrationSubnetPrefix
    dbPrivateEndpointsSubnetPrefix: dbPrivateEndpointsSubnetPrefix
    kvPrivateEndpointsSubnetPrefix: kvPrivateEndpointsSubnetPrefix
  }
}


module privateDnsZoneDb 'modules/private-dns.bicep' = {
  name: 'private-dns-zone-mysql-server'
  params: {
    dnsZoneName: dnsZoneDbName
    virtualNetworkId: vnet.outputs.virtualNetworkId
    virtualNetworkName: vnet.name
  }
}


module privateDnsZoneKeyvault 'modules/private-dns.bicep' = {
  name: 'private-dns-zone-keyvault'
  params: {
    dnsZoneName: dnsZoneKvName
    virtualNetworkId: vnet.outputs.virtualNetworkId
    virtualNetworkName: vnet.name
  }
}


module managedIdentityCms 'modules/managed-identity.bicep' = {
  name: 'managed-identity-cms'
  params: {
    location: location
    resourcePrefix: resourcePrefixCms
  }
}


module acrPullRbacCms 'modules/acr-pull-role-assignment.bicep' = {
  name: 'acr-pull-rbac-cms'
  scope: resourceGroup(sharedServicesResourceGroup)
  params: {
    resourcePrefix: resourcePrefixCms
    principalId: managedIdentityCms.outputs.principalId
  }
}


module communicationServiceRbacCms 'modules/communication-service-rbac.bicep' = {
  name: 'communication-service-rbac-cms'
  scope: resourceGroup(sharedServicesResourceGroup)
  params: {
    resourcePrefix: resourcePrefixCms
    principalId: managedIdentityCms.outputs.principalId
  }
}


module managedIdentityWebsite 'modules/managed-identity.bicep' = {
  name: 'managed-identity-website'
  params: {
    location: location
    resourcePrefix: resourcePrefixWebsite
  }
}


module acrPullRbacWebsite 'modules/acr-pull-role-assignment.bicep' = {
  name: 'acr-pull-rbac-website'
  scope: resourceGroup(sharedServicesResourceGroup)
  params: {
    resourcePrefix: resourcePrefixWebsite
    principalId: managedIdentityWebsite.outputs.principalId
  }
}



