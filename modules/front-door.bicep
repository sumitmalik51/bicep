@description('Unique string')
param resourcePrefix string = 'env'

@description('SKU value for FrontDoor')
param frontDoorSku string = 'Standard_AzureFrontDoor'

@description('SKU value for CDN')
param cdnSku string = 'Standard_Microsoft'

@description('WAF policy name')
param wafName string = 'smasdfv'

@description('WAF policy location')
param wafLocation string = 'global'

param deployWafAndCdn bool = true

resource wafPolicy 'Microsoft.Network/frontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: '${wafName}-policy'
  location: wafLocation
  properties: {
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
     
    }
  }
}

resource frontDoorProfile 'Microsoft.Cdn/profiles@2021-06-01' = if (deployWafAndCdn){
  name: '${resourcePrefix}-front-door-profile'
  location: 'global'
  sku: {
    name: frontDoorSku
  }
  properties: {
    webApplicationFirewallPolicyLink: {
      id: wafPolicy.id
    }
  }
  
}

resource cdnProfile 'Microsoft.Cdn/profiles@2021-06-01' = if (deployWafAndCdn) {
  name: '${resourcePrefix}-cdn-profile'
  location: 'global'
  sku: {
    name: cdnSku
  }
  kind: 'frontdoor'
}

output frontDoorProfileId string = frontDoorProfile.id
output cdnProfileId string = cdnProfile.id
