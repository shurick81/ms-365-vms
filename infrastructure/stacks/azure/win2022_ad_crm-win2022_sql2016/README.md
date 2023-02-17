# Set variables

Review variable values in `.\shared.variables.ps1`.

# Build images

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2016\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_AD_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_AD_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:light `
    build -only azure-arm win2022-ad.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_AD_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_AD_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:light \
    build -only azure-arm win2022-ad.json
```

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2016\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_SQL2016_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_SQL2016_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:light `
    build -only azure-arm win2022-sql2016.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_SQL2016_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_SQL2016_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:light \
    build -only azure-arm win2022-sql2016.json
```

# Provisioning stacks

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2016\shared-variables-ignore-soft.ps1
$env:MS_365_VMS_STACK_TYPE_ID = "win2022_ad_crm-win2022_sql2016";
$env:MS_365_VMS_STACK_INSTANCE_ID = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-dev-00";
$env:MS_365_VMS_WIN2022_AD_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_AD_IMAGE_NAME"
$env:MS_365_VMS_WIN2022_SQL2016_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_SQL2016_IMAGE_NAME"
cd c:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2016;
Remove-Item terraform.tfstate.d -Recurse
Start-Sleep 5;
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 init
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 workspace new $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 workspace select $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 apply -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2022_AD_IMAGE_ID=$env:MS_365_VMS_WIN2022_AD_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_AD_VM_SIZE=$env:MS_365_VMS_WIN2022_AD_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_SQL2016_IMAGE_ID=$env:MS_365_VMS_WIN2022_SQL2016_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_SQL2016_VM_SIZE=$env:MS_365_VMS_WIN2022_AD_VM_SIZE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_DOMAIN_NAME=$env:MS_365_VMS_DOMAIN_NAME" `
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$env:MS_365_VMS_VM_ADMIN_PASSWORD" `
    -var "MS_365_VMS_DOMAIN_ADMIN_PASSWORD=$env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD" `
    -var "RS_SERVICE_PASSWORD=$env:RS_SERVICE_PASSWORD" `
    -var "CRM_TEST_1_PASSWORD=$env:CRM_TEST_1_PASSWORD" `
    -var "CRM_TEST_2_PASSWORD=$env:CRM_TEST_2_PASSWORD" `
    -var "CRM_INSTALL_PASSWORD=$env:CRM_INSTALL_PASSWORD" `
    -var "CRM_SERVICE_PASSWORD=$env:CRM_SERVICE_PASSWORD" `
    -var "CRM_DEPLOYMENT_SERVICE_PASSWORD=$env:CRM_DEPLOYMENT_SERVICE_PASSWORD" `
    -var "CRM_SANDBOX_SERVICE_PASSWORD=$env:CRM_SANDBOX_SERVICE_PASSWORD" `
    -var "CRM_VSS_WRITER_PASSWORD=$env:CRM_VSS_WRITER_PASSWORD" `
    -var "CRM_ASYNC_SERVICE_PASSWORD=$env:CRM_ASYNC_SERVICE_PASSWORD" `
    -var "CRM_MONITORING_SERVICE_PASSWORD=$env:CRM_MONITORING_SERVICE_PASSWORD";
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016/shared-variables-ignore-soft.sh
MS_365_VMS_STACK_TYPE_ID="win2022_ad_crm-win2022_sql2016";
MS_365_VMS_STACK_INSTANCE_ID=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-dev-01";
MS_365_VMS_WIN2022_AD_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_AD_IMAGE_NAME"
MS_365_VMS_WIN2022_SQL2016_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_SQL2016_IMAGE_NAME"
cd ~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016;
sudo rm -rf terraform.tfstate.d;
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 init
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 workspace new $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 workspace select $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2016 hashicorp/terraform:1.3.7 apply -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2022_AD_IMAGE_ID=$MS_365_VMS_WIN2022_AD_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_AD_VM_SIZE=$MS_365_VMS_WIN2022_AD_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_SQL2016_IMAGE_ID=$MS_365_VMS_WIN2022_SQL2016_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_SQL2016_VM_SIZE=$MS_365_VMS_WIN2022_SQL2016_VM_SIZE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_DOMAIN_NAME=$MS_365_VMS_DOMAIN_NAME" \
    -var "MS_365_VMS_VM_ADMIN_PASSWORD=$MS_365_VMS_VM_ADMIN_PASSWORD" \
    -var "MS_365_VMS_DOMAIN_ADMIN_PASSWORD=$MS_365_VMS_DOMAIN_ADMIN_PASSWORD" \
    -var "RS_SERVICE_PASSWORD=$RS_SERVICE_PASSWORD" \
    -var "CRM_TEST_1_PASSWORD=$CRM_TEST_1_PASSWORD" \
    -var "CRM_TEST_2_PASSWORD=$CRM_TEST_2_PASSWORD" \
    -var "CRM_INSTALL_PASSWORD=$CRM_INSTALL_PASSWORD" \
    -var "CRM_SERVICE_PASSWORD=$CRM_SERVICE_PASSWORD" \
    -var "CRM_DEPLOYMENT_SERVICE_PASSWORD=$CRM_DEPLOYMENT_SERVICE_PASSWORD" \
    -var "CRM_SANDBOX_SERVICE_PASSWORD=$CRM_SANDBOX_SERVICE_PASSWORD" \
    -var "CRM_VSS_WRITER_PASSWORD=$CRM_VSS_WRITER_PASSWORD" \
    -var "CRM_ASYNC_SERVICE_PASSWORD=$CRM_ASYNC_SERVICE_PASSWORD" \
    -var "CRM_MONITORING_SERVICE_PASSWORD=$CRM_MONITORING_SERVICE_PASSWORD";
```
