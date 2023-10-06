param kind string = 'classic'

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${appName}-ai'
  location: location
  kind: kind
  properties: {
    Application_Type: 'web'
  }
}
