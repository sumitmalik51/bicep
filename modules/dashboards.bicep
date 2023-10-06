param dashboardname
resource dashboard 'Microsoft.Portal/dashboards@2019-09-01-preview' = {
  name: dashboardname
  location: location
  properties: {
    lenses: [
      {
        name: 'webAppHealth'
        properties: {
          widgetType: 'metric'
          metrics: [
            {
              resourceId: webApp.id
              metricName: 'Http2xx'
            }
            {
              resourceId: webApp.id
              metricName: 'Http4xx'
            }
            {
              resourceId: webApp.id
              metricName: 'Http5xx'
            }
          ]
          timeContext: {
            duration: 'PT1H'
            endTime: null
          }
          xAxis: {
            type: 'DateTime'
          }
          yAxis: {
            label: 'Requests'
            format: '0'
          }
        }
      }
    ]
  }
}
