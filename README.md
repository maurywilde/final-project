# User guide for the Infrastructure

In order to start working on this application we need to fork it [here](https://github.com/juanjodevops/microservices-demo)


## Prerequisites 

- Install Azure CLI
- Login using the command `az login`
- Creating a Resource Group in Azure


In this part I used a Resource Group created in the Azure portal.

- Resource Group: final-project
- Service Principal: fp-sp
- Storage Account: fpstorage

---

## Creating a Storage Account for Terraform storage

Due to the fact that Terraform state is stored locally, it is not ideal for the following reasons:

- Does not work well in a team enviroment
- Terraform can include sensitive information
- Storing state locally can increase the chances of deletion without a warning

## Create storage account
az storage account create --resource-group final-project --name fpstorage --sku Standard_LRS --encryption-services blob

## Create a Service Principal 
az ad sp create-for-rbac --name fp-sp --role Contributor

{
  "appId": "cab08a03-eb6f-48dc-b3af-8d53c38e0917",
  "displayName": "fp-sp",
  "name": "cab08a03-eb6f-48dc-b3af-8d53c38e0917",
  "password": "Rj6thZVY.SBkI9_VFL-DcRWWGQowJqFTOt",
  "tenant": "c8cd0425-e7b7-4f3d-9215-7e5fa3f439e8"
}

---

# Authenticate Terraform to Azure

## View the account list
az account list --query "[?user.name=='juan.cervantes@digitalonus.com'].{Name:name, ID:id, Default:isDefault}" --output Table

## Use a specific Azure subscription 
az account set --subscription "84ad5de5-966f-4a2b-bce9-d462b5a9bbec"

## Specify service principal credentials in enviroment variables

export ARM_SUBSCRIPTION_ID="84ad5de5-966f-4a2b-bce9-d462b5a9bbec"
export ARM_TENANT_ID="c8cd0425-e7b7-4f3d-9215-7e5fa3f439e8"
export ARM_CLIENT_ID="cab08a03-eb6f-48dc-b3af-8d53c38e0917"
export ARM_CLIENT_SECRET="Rj6thZVY.SBkI9_VFL-DcRWWGQowJqFTOt"

## Get storage account key
az storage account keys list --resource-group final-project --account-name fpstorage 

juancervantes@JuanCervantes-MacBook-Pro:~/Desktop/final-project » az storage account keys list --resource-group final-project --account-name fpstorage
[
  {
    "creationTime": "2021-11-24T03:16:20.555358+00:00",
    "keyName": "key1",
    "permissions": "FULL",
    "value": "fNhr0FrwP0sovY+a3FduLFPCayDM10gQVhF0UdbC7U0G1i2SkhfchvYt/BtTU8lSz8m+9KcIQ0LloOrU0sxruA=="
  },
  {
    "creationTime": "2021-11-24T03:16:20.555358+00:00",
    "keyName": "key2",
    "permissions": "FULL",
    "value": "QaSnNNWIGXnpfks+D8BCls2g9KTdGCwcvUyBuoTVhBm5noYGpUlFVfOijp4V0RjjZDUZsHk+KwoOciTHHGtFrQ=="
  }
]

// export STORAGE_ACCOUNT_KEY="QaSnNNWIGXnpfks+D8BCls2g9KTdGCwcvUyBuoTVhBm5noYGpUlFVfOijp4V0RjjZDUZsHk+KwoOciTHHGtFrQ=="

## Create blob container
az storage container create --name fp-container --account-name fpstorage --account-key $STORAGE_ACCOUNT_KEY

echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
echo "container_name: $CONTAINER_NAME"
echo "access_key: $ACCOUNT_KEY"`


## Create a Key Vault and store secret
az keyvault create --name "fp-keysecret" --resource-group "final-project"


az keyvault secret set --vault-name "fp-keysecret" --name "fp-accesskey" --value $STORAGE_ACCOUNT_KEY

## With this command we can access the value
az keyvault secret show --name "fp-accesskey" --vault-name "fp-keysecret" --query value -o tsv
