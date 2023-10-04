```sh
# Login to Azure using CLI, the following command will output the URL and authentication code
# Open the URL in any browser, enter the authentication code when prompted and complete the 
# authentication process using Supreme Court email account
az login --use-device-code

# When there are multiple AZ accounts configured set the UKSC-Dev as active subscription 
az account set --subscription UKSC-Dev

# Create resource group persistent
az group create --name persistent --location uksouth

# Deploy persistent resources using persistent.bicep file
az deployment group create --resource-group persistent --template-file persistent.bicep

# Create resource group components
az group create --name components --location uksouth

# Deploy components resources using components.bicep file
az deployment group create --resource-group components --template-file components.bicep

# Delete resource group components
az group delete --name components -y

# Delete resource group persistent
az group delete --name persistent -y
```
