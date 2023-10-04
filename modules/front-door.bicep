@description('Unique string')
param resourcePrefix string 

@description('SKU value for FrontDoor')
param frontDoorSku string 



resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: '${resourcePrefix}-front-door-profile'
  location: 'global'
  sku: {
    name: frontDoorSku
  }
}

output id string = frontDoorProfile.properties.frontDoorId
