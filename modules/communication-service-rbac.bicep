@description('Unique string')
param resourcePrefix string 

@description('Principal Id for assigning role')
param principalId string

@description('''
The resource name of azure communication service
''')
param communicationServiceName string

@description('''
This is the built-in contributor role.
See https://learn.microsoft.com/en-gb/azure/role-based-access-control/built-in-roles#contributor
''')
param contributorBuiltInRoleId string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

resource communicationService 'Microsoft.Communication/communicationServices@2023-04-01-preview' existing = {
  name: communicationServiceName
}

resource roleAssignmentMi 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${resourcePrefix}-communication-service-rbac')
  scope: communicationService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', contributorBuiltInRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
