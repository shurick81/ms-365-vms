# Set variables

Review variable values in `.\shared.variables.ps1`.

# Build images

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_wp-terraform0\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_WP_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_WP_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:1.8.5 `
    build -only azure-arm win2022-wp.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_wp-terraform0/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_WP_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_WP_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:1.8.5 \
    build -only azure-arm win2022-wp.json
```

# Provisioning stacks

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_wp-terraform0\shared-variables-ignore-soft.ps1
$env:MS_365_VMS_STACK_TYPE_ID = "win2022_wp-terraform0";
$env:MS_365_VMS_STACK_INSTANCE_ID = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-dev-00";
$env:MS_365_VMS_WIN2022_WP_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_WP_IMAGE_NAME"
cd c:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_wp-terraform0;
Remove-Item terraform.tfstate.d -Recurse
Start-Sleep 5;
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2022_WP_IMAGE_ID=$env:MS_365_VMS_WIN2022_WP_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_WP_VM_SIZE=$env:MS_365_VMS_WIN2022_WP_VM_SIZE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$env:MS_365_VMS_VM_ADMIN_PASSWORD" `
    -var "MS_365_VMS_PIPELINE_PROVIDER=$env:MS_365_VMS_PIPELINE_PROVIDER" `
    -var "MS_365_VMS_PIPELINE_URL=$env:MS_365_VMS_PIPELINE_URL" `
    -var "MS_365_VMS_PIPELINE_TOKEN=$env:MS_365_VMS_PIPELINE_TOKEN" `
    -var "MS_365_VMS_PIPELINE_STACK_LABEL=$env:MS_365_VMS_STACK_INSTANCE_ID" `
    -var "MS_365_VMS_PIPELINE_ACCOUNT_UIID=$env:MS_365_VMS_PIPELINE_ACCOUNT_UI" `
    -var "MS_365_VMS_PIPELINE_REPOSITORY_UIID=$env:MS_365_VMS_PIPELINE_REPOSITORY_UI" `
    -var "MS_365_VMS_PIPELINE_RUNNER_UIID=$env:MS_365_VMS_PIPELINE_RUNNER_UI" `
    -var "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID=$env:MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID";
```


```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_wp-terraform0/shared-variables-ignore-soft.sh
MS_365_VMS_STACK_TYPE_ID="win2022_wp-terraform0";
MS_365_VMS_STACK_INSTANCE_ID=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-dev-00";
MS_365_VMS_DNS_PREFIX=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-00-";
MS_365_VMS_WIN2022_WP_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_WP_IMAGE_NAME"
cd ~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_wp-terraform0;
sudo rm -rf terraform.tfstate.d;
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2022_WP_IMAGE_ID=$MS_365_VMS_WIN2022_WP_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_WP_VM_SIZE=$MS_365_VMS_WIN2022_WP_VM_SIZE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$MS_365_VMS_VM_ADMIN_PASSWORD" \
    -var "MS_365_VMS_PIPELINE_PROVIDER=$MS_365_VMS_PIPELINE_PROVIDER" \
    -var "MS_365_VMS_PIPELINE_URL=$MS_365_VMS_PIPELINE_URL" \
    -var "MS_365_VMS_PIPELINE_TOKEN=$MS_365_VMS_PIPELINE_TOKEN" \
    -var "MS_365_VMS_PIPELINE_STACK_LABEL=$MS_365_VMS_STACK_INSTANCE_ID" \
    -var "MS_365_VMS_PIPELINE_ACCOUNT_UIID=$MS_365_VMS_PIPELINE_ACCOUNT_UIID" \
    -var "MS_365_VMS_PIPELINE_REPOSITORY_UIID=$MS_365_VMS_PIPELINE_REPOSITORY_UIID" \
    -var "MS_365_VMS_PIPELINE_RUNNER_UIID=$MS_365_VMS_PIPELINE_RUNNER_UIID" \
    -var "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID=$MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID";
```

```bash
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_wp-terraform0 hashicorp/terraform:0.11.15 taint -module=WP00 azurerm_virtual_machine.main
```
