param resourcePrefix string
param principalId string
param acrName string
param acrPullBuiltInRoleId string = '7f951dda-4ed3-4680-a7ca-43fe172d538d'


resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}


resource roleAssignmentMi 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${resourcePrefix}-acr-pull-role-assignment')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullBuiltInRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
