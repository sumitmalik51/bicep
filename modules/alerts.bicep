param location string  
param appid string

resource HTTPmetricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'HTTP metric alert'
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      appid
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 1
          name: 'Metric1'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          timeAggregation: 'Total'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Web/sites'
    targetResourceRegion: location
    actions: []
  }
}

resource responsemetricAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: 'app response time'
  location: 'global'
  properties: {
    severity: 3
    enabled: true
    scopes: [
      appid
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      allOf: [
        {
          threshold: 100
          name: 'Metric1'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'HealthCheckStatus'
          operator: 'LessThan'
          timeAggregation: 'Average'
          skipMetricValidation: false
          criterionType: 'StaticThresholdCriterion'
        }
      ]
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Web/sites'
    targetResourceRegion: location
    actions: []
  }
}
