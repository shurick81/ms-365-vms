# Set variables

Review variable values in `.\shared.variables.ps1`.

# Build images

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_hyperv\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_HYPERV_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_HYPERV_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:1.8.7 `
    build -only azure-arm.* win2022-hyperv.pkr.hcl
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_hyperv/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_HYPERV_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_HYPERV_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:1.8.7 \
    build -only azure-arm.* win2022-hyperv.pkr.hcl
```

# Provisioning stacks

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_hyperv\shared-variables-ignore-soft.ps1
$env:MS_365_VMS_STACK_TYPE_ID = "win2022_hyperv";
$env:MS_365_VMS_STACK_INSTANCE_ID = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-dev-00";
$env:MS_365_VMS_WIN2022_HYPERV_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_HYPERV_IMAGE_NAME"
cd c:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_hyperv;
Remove-Item terraform.tfstate.d -Recurse
Start-Sleep 5;
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 init
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 workspace new $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 workspace select $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 apply -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2022_HYPERV_IMAGE_ID=$env:MS_365_VMS_WIN2022_HYPERV_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_HYPERV_VM_SIZE=$env:MS_365_VMS_WIN2022_HYPERV_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_HYPERV_DISK_TYPE=$env:MS_365_VMS_WIN2022_HYPERV_DISK_TYPE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$env:MS_365_VMS_VM_ADMIN_PASSWORD" `
    -var "MS_365_VMS_PIPELINE_PROVIDER=$env:MS_365_VMS_PIPELINE_PROVIDER" `
    -var "MS_365_VMS_PIPELINE_URL=$env:MS_365_VMS_PIPELINE_URL" `
    -var "MS_365_VMS_PIPELINE_TOKEN=$env:MS_365_VMS_PIPELINE_TOKEN" `
    -var "MS_365_VMS_PIPELINE_STACK_LABEL=$env:MS_365_VMS_STACK_INSTANCE_ID" `
    -var "MS_365_VMS_PIPELINE_ACCOUNT_UIID=$env:MS_365_VMS_PIPELINE_ACCOUNT_UI" `
    -var "MS_365_VMS_PIPELINE_REPOSITORY_UIID=$env:MS_365_VMS_PIPELINE_REPOSITORY_UI" `
    -var "MS_365_VMS_PIPELINE_RUNNER_UIID=$env:MS_365_VMS_PIPELINE_RUNNER_UI" `
    -var "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID=$env:MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID" `
    -var "MS_365_VMS_PIPELINE_RUNNER_VERSION=$env:MS_365_VMS_PIPELINE_RUNNER_VERSION";
```


```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_hyperv/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_hyperv;
sudo rm -rf terraform.tfstate.d;
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 init
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 workspace new $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 workspace select $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 apply -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2022_HYPERV_IMAGE_ID=$MS_365_VMS_WIN2022_HYPERV_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_HYPERV_VM_SIZE=$MS_365_VMS_WIN2022_HYPERV_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_HYPERV_DISK_TYPE=$MS_365_VMS_WIN2022_HYPERV_DISK_TYPE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$MS_365_VMS_VM_ADMIN_PASSWORD" \
    -var "MS_365_VMS_PIPELINE_PROVIDER=$MS_365_VMS_PIPELINE_PROVIDER" \
    -var "MS_365_VMS_PIPELINE_URL=$MS_365_VMS_PIPELINE_URL" \
    -var "MS_365_VMS_PIPELINE_TOKEN=$MS_365_VMS_PIPELINE_TOKEN" \
    -var "MS_365_VMS_PIPELINE_STACK_LABEL=$MS_365_VMS_STACK_INSTANCE_ID" \
    -var "MS_365_VMS_PIPELINE_ACCOUNT_UIID=$MS_365_VMS_PIPELINE_ACCOUNT_UIID" \
    -var "MS_365_VMS_PIPELINE_REPOSITORY_UIID=$MS_365_VMS_PIPELINE_REPOSITORY_UIID" \
    -var "MS_365_VMS_PIPELINE_RUNNER_UIID=$MS_365_VMS_PIPELINE_RUNNER_UIID" \
    -var "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID=$MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID" \
    -var "MS_365_VMS_PIPELINE_RUNNER_VERSION=$MS_365_VMS_PIPELINE_RUNNER_VERSION";
```

```bash
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 destroy -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2022_HYPERV_IMAGE_ID=$MS_365_VMS_WIN2022_HYPERV_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_HYPERV_VM_SIZE=$MS_365_VMS_WIN2022_HYPERV_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_HYPERV_DISK_TYPE=$MS_365_VMS_WIN2022_HYPERV_DISK_TYPE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$MS_365_VMS_VM_ADMIN_PASSWORD" \
    -var "MS_365_VMS_PIPELINE_PROVIDER=$MS_365_VMS_PIPELINE_PROVIDER" \
    -var "MS_365_VMS_PIPELINE_URL=$MS_365_VMS_PIPELINE_URL" \
    -var "MS_365_VMS_PIPELINE_TOKEN=$MS_365_VMS_PIPELINE_TOKEN" \
    -var "MS_365_VMS_PIPELINE_STACK_LABEL=$MS_365_VMS_STACK_INSTANCE_ID" \
    -var "MS_365_VMS_PIPELINE_ACCOUNT_UIID=$MS_365_VMS_PIPELINE_ACCOUNT_UIID" \
    -var "MS_365_VMS_PIPELINE_REPOSITORY_UIID=$MS_365_VMS_PIPELINE_REPOSITORY_UIID" \
    -var "MS_365_VMS_PIPELINE_RUNNER_UIID=$MS_365_VMS_PIPELINE_RUNNER_UIID" \
    -var "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID=$MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID" \
    -var "MS_365_VMS_PIPELINE_RUNNER_VERSION=$MS_365_VMS_PIPELINE_RUNNER_VERSION";
```

```bash
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_hyperv hashicorp/terraform:1.4.6 taint module.SERVER00.azurerm_windows_virtual_machine.main
```

# Access the VM

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.48.1 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    vm_name=$(printf $MS_365_VMS_VM_NAME_SPEC "server00");
    az network public-ip show --id /subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_STACK_INSTANCE_ID/providers/Microsoft.Network/publicIPAddresses/\$vm_name\-pip --query 'ipAddress' -o tsv"
```

# Turn on the VM

```bash
docker run -it --rm mcr.microsoft.com/azure-cli:2.48.1 /bin/bash -c "az login --service-principal -u $ARM_CLIENT_ID -p $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID;
    vm_name=$(printf $MS_365_VMS_VM_NAME_SPEC "server00");
    az vm show --id /subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_STACK_INSTANCE_ID/providers/Microsoft.Compute/virtualMachines/\$vm_name"
```
