@description('''
The resource name for communication service
- Character limit: 1-63
- Valid characters: Alphanumerics and hyphens.
- Can't start or end with hyphen.
- Can't use underscores.
- Resource name must be unique across Azure.
''')
param communicationServiceName string = 'uksc-communication-service-dev'

@description('The resource name for email communication service')
param emailServiceName string = 'uksc-email-service-dev'

@description('The geo-location where the resource lives')
param location string = 'global'

@description('The location where the email service stores its data at rest')
param dataLocation string = 'UK'

@description('''
The custom domain name to be used with email communication service.
This will only be used in staging and prod environments.
For all other environments we will be using Azure Managed domain
''')
param customDomainName string = ''

@description('A sender username to be used when sending emails')
param senderUserName string = 'DoNotReply'

resource emailService 'Microsoft.Communication/emailServices@2023-04-01-preview' = {
  name: emailServiceName
  location: location
  properties: {
    dataLocation: dataLocation
  }
}

resource emailServiceDomain 'Microsoft.Communication/emailServices/domains@2023-03-31' = {
  parent: emailService
  name: (empty(customDomainName)) ? 'AzureManagedDomain' : customDomainName
  location: location
  properties: {
    domainManagement: (empty(customDomainName)) ? 'AzureManaged' : 'CustomerManaged'
    userEngagementTracking: 'Disabled'
  }
}

resource emailServiceDomainSenderUserName 'Microsoft.Communication/emailServices/domains/senderUsernames@2023-03-31' = if (empty(customDomainName)) {
  parent: emailServiceDomain
  name: toLower(senderUserName)
  properties: {
    username: senderUserName
    displayName: senderUserName
  }
}

resource communcationService 'Microsoft.Communication/communicationServices@2023-03-31' = {
  name: communicationServiceName
  location: location
  properties: {
    dataLocation: dataLocation
    linkedDomains: [
      emailServiceDomain.id
    ]
  }
}

