resource alertRule 'Microsoft.Insights/activityLogAlerts@2017-04-01-preview' = {
  name: 'webapp-alert'
  location: resourceGroup().location
  properties: {
    scopes: [
      webApp.id
    ]
    condition: {
      allOf: [
        {
          field: 'category'
          equals: 'AppServiceAuditLogs'
        },
        {
          field: 'operationName'
          equals: 'Microsoft.Web/sites/write'
        },
        {
          field: 'resourceType'
          equals: 'Microsoft.Web/sites'
        },
        {
          field: 'status'
          equals: 'Failed'
        }
      ]
    }
  
  }
}

