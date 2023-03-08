# If app identity is not created yet, create it

Feel free to login to Azure using Docker or using Azure Cloud Shell.
## Use Docker for login to Azure

1. Start an Azure CLI container

```
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0
```

2. Run the following command in the container:

```
az login
```

Follow the instructions in order to authenticate.

## Use Azure Cloud Shell

1. Authenticate in https://portal.azure.com/

2. Select the directory (tenant) you want to manage

3. Open Cloud Shell in bash mode

## Finish creating the app identity

1. In the container or in Cloud Shell, run the following command to list tenants and subscriptions:

```bash
echo 'tenantId                                Subscription id                         Default Subscription name';
az account list --query '[].[tenantId,id,isDefault,name]' -o tsv;
```

2. Then following commands to select a specific subscription that you want to use by the application identity:

```bash
az account set --subscription aa5afb6f-7b74-4b41-ab20-32ae27b0ce38
```

3. Create the app with comprehensive data output:

```
az ad sp create-for-rbac --name RND-DEV-KOLLO_FORV-infrastructure-scripts-00 --skip-assignment
```

Alternatively, you can update existing identity instead of creating a new one:

```
az ad sp credential reset --id 868e996c-4d0f-4af2-9f48-6a2db84a5326
az ad sp credential reset --name SPT-Software-ServiceApp
```

## Compose variable files

For example:

```PowerShell
$env:ARM_CLIENT_ID = "531adb66-98a5-4e6b-b407-b1961a2794e1";
$env:ARM_CLIENT_SECRET = "xxxx";
$env:ARM_SUBSCRIPTION_ID = "d7c7a3af-f74f-4007-845c-dcacef601c53";
$env:ARM_TENANT_ID = "8b87af7d-8647-4dc7-8df4-5f69a2011bb5";
```

## Verify connection

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az account show --subscription $env:ARM_SUBSCRIPTION_ID"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    az account show --subscription $ARM_SUBSCRIPTION_ID"
```

# If an image resource group is not ready, create it

Image resource group is CommonRGWestEurope by default if not altered in variable files.

Create it if not done:
```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group create --subscription $env:ARM_SUBSCRIPTION_ID -n CommonRGWestEurope -l westeurope"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    az group create --subscription $ARM_SUBSCRIPTION_ID -n CommonRGWestEurope -l westeurope"
```

# If file share is not ready, create it (needed for some stacks)

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az storage account create --subscription $env:ARM_SUBSCRIPTION_ID -n softwestdlrsv20 -g CommonRGWestEurope -l westeurope --sku Standard_LRS --kind StorageV2 `
    az storage account keys list --subscription $env:ARM_SUBSCRIPTION_ID --account-name softwestdlrsv20 `
    az storage share create --subscription $env:ARM_SUBSCRIPTION_ID --account-name softwestdlrsv20 --name common-00"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    az storage account create --subscription $ARM_SUBSCRIPTION_ID -n ms365vmswestdlrsv20 -g CommonRGWestEurope -l westeurope --sku Standard_LRS --kind StorageV2;
    az storage account keys list --subscription $ARM_SUBSCRIPTION_ID --account-name ms365vmswestdlrsv20;
    az storage share create --subscription $ARM_SUBSCRIPTION_ID --account-name ms365vmswestdlrsv20 --name common-00"
```

save key value to env variables

# Common snippets

before using, set up `$env:MS_365_VMS_STACK_INSTANCE_ID`

## Destroy the stack

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group delete --subscription $env:ARM_SUBSCRIPTION_ID -n $env:MS_365_VMS_STACK_INSTANCE_ID -y"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID; \
    az group delete --subscription $ARM_SUBSCRIPTION_ID -n $MS_365_VMS_STACK_INSTANCE_ID -y"
```

## List VMs with status

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az vm list -d --subscription $env:ARM_SUBSCRIPTION_ID -g $env:MS_365_VMS_STACK_INSTANCE_ID -o table"
```

## Start machines

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az vm start --ids `$( az vm list --query '[].id' -o tsv --subscription $env:ARM_SUBSCRIPTION_ID -g $env:MS_365_VMS_STACK_INSTANCE_ID )"
```

## Stop machines

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az vm deallocate --ids `$( az vm list --query '[].id' -o tsv --subscription $env:ARM_SUBSCRIPTION_ID -g $env:MS_365_VMS_STACK_INSTANCE_ID )"
```

## List RGs

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group list --query '[].name' -o tsv --subscription $env:ARM_SUBSCRIPTION_ID"
```

## Destroy an RG

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group delete --subscription $env:ARM_SUBSCRIPTION_ID -n pkr-Resource-Group-byd9he88e5 -y"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID; \
    az group delete --subscription $ARM_SUBSCRIPTION_ID -n pkr-Resource-Group-byd9he88e5 -y"
```

## List images

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az image list --subscription $env:ARM_SUBSCRIPTION_ID -g $env:MS_365_VMS_IMAGE_RG_NAME -o table"
```

## Delete an image

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az image delete --subscription $env:ARM_SUBSCRIPTION_ID -g $env:MS_365_VMS_IMAGE_RG_NAME -n win2019-sql2019-rs-20201029..99"
```

## Create snapshots

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "ARM_CLIENT_ID='$env:ARM_CLIENT_ID'; ARM_CLIENT_SECRET='$env:ARM_CLIENT_SECRET'; ARM_TENANT_ID='$env:ARM_TENANT_ID'; ENVIRONMENTID='$env:MS_365_VMS_STACK_INSTANCE_ID'; ARM_SUBSCRIPTION_ID='$env:ARM_SUBSCRIPTION_ID'; `
    az login --service-principal -u `$ARM_CLIENT_ID -p `$ARM_CLIENT_SECRET --tenant `$ARM_TENANT_ID; `
    az vm deallocate --ids `$(az vm list --query '[].id' -o tsv -g `$ENVIRONMENTID); `
    VMNames=`$(az vm list --query '[].[name]' -o tsv -g `$ENVIRONMENTID); `
    for VMname in `${VMNames[@]} `
    do `
        az snapshot create -g `$ENVIRONMENTID -n `$VMname-base -l westeurope --source /subscriptions/`$ARM_SUBSCRIPTION_ID/resourceGroups/`$ENVIRONMENTID/providers/Microsoft.Compute/disks/`$VMname-disk-os; `
    done"
```

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "ENVIRONMENTID='$MS_365_VMS_STACK_INSTANCE_ID';
    az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    az vm deallocate --ids \$(az vm list --query '[].id' -o tsv -g \$ENVIRONMENTID);
    VMNames=\$(az vm list --query '[].[name]' -o tsv -g \$ENVIRONMENTID);
    for VMname in \${VMNames[@]}
    do
        az snapshot create -g \$ENVIRONMENTID -n \$VMname-base -l westeurope --source /subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/\$ENVIRONMENTID/providers/Microsoft.Compute/disks/\$VMname-disk-os;
    done"
```

docker run -it --rm mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "echo '$ARM_CLIENT_ID'; \
az"

## Rollback to snapshots

```PowerShell
docker run -it --rm -v ${pwd}/../azure-cli:/root -w /root mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "export ARM_CLIENT_ID='$env:ARM_CLIENT_ID'; export ARM_CLIENT_SECRET='$env:ARM_CLIENT_SECRET'; export ARM_TENANT_ID='$env:ARM_TENANT_ID'; export ENVIRONMENTID='$env:MS_365_VMS_STACK_INSTANCE_ID'; export ARM_SUBSCRIPTION_ID='$env:ARM_SUBSCRIPTION_ID'; `
    ./snapshotRollback.sh"
```

```bash
sudo chmod +x ./../azure-cli/snapshotRollback.sh
docker run -it --rm -v $(pwd)/../azure-cli:/root -w /root mcr.microsoft.com/azure-cli:2.16.0 /bin/bash -c "export ARM_CLIENT_ID='$ARM_CLIENT_ID'; export ARM_CLIENT_SECRET='$ARM_CLIENT_SECRET'; export ARM_TENANT_ID='$ARM_TENANT_ID'; export ENVIRONMENTID='$MS_365_VMS_STACK_INSTANCE_ID'; export ARM_SUBSCRIPTION_ID='$ARM_SUBSCRIPTION_ID'; \
    ./snapshotRollback.sh"
```

## Remove all temporary Packer groups

```
az group list --query "[?starts_with(name, 'pkr-Resource-Group-')].name" --output tsv |
while read -r resourceGroup; do
    az group delete --name $resourceGroup --no-wait -y
done
```
