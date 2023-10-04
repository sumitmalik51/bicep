@description('location')
param location string


@description('resourcePrefix for deployment of resources')
param resourcePrefix string


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


// resource nsg 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
//   name: '${resourcePrefix}-allow-vnet-internal-traffic'
//   location: location
//   properties: {
//     securityRules: [
//       {
//         name: '${resourcePrefix}-allow-app-services-vnet-traffic'
//         properties: {
//           description: 'Allow traffic from app services VNet integration subnet'
//           protocol: 'Tcp'
//           sourcePortRange: '*'
//           destinationPortRange: '*'
//           sourceAddressPrefix: '10.0.0.0/24'
//           destinationAddressPrefix: '*'
//           access: 'Allow'
//           priority: 100
//           direction: 'Inbound'
//         }
//       }
//     ]
//   }
// }

resource nsgPrivateEndpointSubnet 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: '${resourcePrefix}-allow-vnet-internal-traffic-sg'
  location: location
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkAddressPrefix
      ]
    }
    subnets: [
      {
        name: appServicesVnetIntegrationSubnetName
        properties: {
          addressPrefix: appServicesVnetIntegrationSubnetPrefix
          delegations: [
            {
              name: 'app-services-vnet-integration-subnet-delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
          networkSecurityGroup: {
            id: nsgPrivateEndpointSubnet.id
          }
        }
      }
      {
        name: dbPrivateEndpointsSubnetName
        properties: {
          addressPrefix: dbPrivateEndpointsSubnetPrefix
          delegations: [
            {
              name: 'dlg-Microsoft.DBforMySQL-flexibleServers'
              properties: {
                serviceName: 'Microsoft.DBforMySQL/flexibleServers'
              }
            }
          ]
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: nsgPrivateEndpointSubnet.id
          }
        }
      }
      {
        name: kvPrivateEndpointsSubnetName
        properties: {
          addressPrefix: kvPrivateEndpointsSubnetPrefix
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: nsgPrivateEndpointSubnet.id
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.KeyVault'
            }
          ]
        }
      }
    ]
  }
}


output virtualNetworkId string = virtualNetwork.id
output vnetIntegrationSubnetId string = virtualNetwork.properties.subnets[0].id
output vnetIntegrationSubnetIpRange string = virtualNetwork.properties.subnets[0].properties.addressPrefix
output dbPrivateEndpointsSubnetId string = virtualNetwork.properties.subnets[1].id
output kvPrivateEndpointsSubnetId string = virtualNetwork.properties.subnets[2].id
