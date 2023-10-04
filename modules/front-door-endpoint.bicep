param frontDoorResourceName string
param resourcePrefix string

resource frontDoorProfile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: frontDoorResourceName
}

resource endpoint 'Microsoft.Cdn/profiles/afdEndpoints@2023-05-01' = {
  parent: frontDoorProfile
  name: resourcePrefix
  location: 'global'
  properties: {
    enabledState: 'Enabled'
  }
}

output endpointHostName string = endpoint.properties.hostName
