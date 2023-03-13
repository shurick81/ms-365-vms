# Set variables

Review variable values in `.\shared.variables.ps1`.

# Build images

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0\shared-variables-ignore-soft.ps1
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
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0/shared-variables-ignore-soft.sh
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
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_SQL2022_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_SQL2022_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:light `
    build -only azure-arm win2022-sql2022.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_SQL2022_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_SQL2022_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:light \
    build -only azure-arm win2022-sql2022.json
```

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_WEB_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_WEB_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:light `
    build -only azure-arm win2022-web.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_WEB_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_WEB_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:light \
    build -only azure-arm win2022-web.json
```

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_file\shared-variables-ignore-soft.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2022_SOE_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2022_SOE_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:light `
    build -only azure-arm win2022-soe.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_file/shared-variables-ignore-soft.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2022_SOE_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2022_SOE_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:light \
    build -only azure-arm win2022-soe.json
```

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_file\shared-variables-ignore-soft.ps1
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
    hashicorp/packer:light `
    build -only azure-arm win2022-wp.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_file/shared-variables-ignore-soft.sh
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
    hashicorp/packer:light \
    build -only azure-arm win2022-wp.json
```

# Provisioning stacks

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0\shared-variables-ignore-soft.ps1
$env:MS_365_VMS_STACK_TYPE_ID = "win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-wp-tf0";
$env:MS_365_VMS_STACK_INSTANCE_ID = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-dev00";
$env:MS_365_VMS_DNS_PREFIX = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-00-";
$env:MS_365_VMS_WIN2022_AD_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_AD_IMAGE_NAME"
$env:MS_365_VMS_WIN2022_SQL2022_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_SQL2022_IMAGE_NAME"
$env:MS_365_VMS_WIN2022_WEB_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_WEB_IMAGE_NAME"
$env:MS_365_VMS_WIN2022_FILES_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_SOE_IMAGE_NAME"
$env:MS_365_VMS_WIN2022_WP_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2022_WP_IMAGE_NAME"
cd c:\projects\ms-365-vms\infrastructure\stacks\azure\win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0;
Remove-Item terraform.tfstate.d -Recurse
Start-Sleep 5;
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2022_AD_IMAGE_ID=$env:MS_365_VMS_WIN2022_AD_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_AD_VM_SIZE=$env:MS_365_VMS_WIN2022_AD_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_SQL2022_IMAGE_ID=$env:MS_365_VMS_WIN2022_SQL2022_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_SQL2022_VM_SIZE=$env:MS_365_VMS_WIN2022_SQL2022_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_WEB_IMAGE_ID=$env:MS_365_VMS_WIN2022_WEB_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_WEB_VM_SIZE=$env:MS_365_VMS_WIN2022_WEB_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_FILES_IMAGE_ID=$env:MS_365_VMS_WIN2022_FILES_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_FILES_VM_SIZE=$env:MS_365_VMS_WIN2022_FILES_VM_SIZE" `
    -var "MS_365_VMS_WIN2022_WP_IMAGE_ID=$env:MS_365_VMS_WIN2022_WP_IMAGE_ID" `
    -var "MS_365_VMS_WIN2022_WP_VM_SIZE=$env:MS_365_VMS_WIN2022_WP_VM_SIZE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_DNS_PREFIX=$env:MS_365_VMS_DNS_PREFIX" `
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
    -var "CRM_MONITORING_SERVICE_PASSWORD=$env:CRM_MONITORING_SERVICE_PASSWORD" `
    -var "MS_365_VMS_SSL_CACHE_UNC=$env:MS_365_VMS_SSL_CACHE_UNC" `
    -var "MS_365_VMS_SSL_CACHE_USERNAME=$env:MS_365_VMS_SSL_CACHE_USERNAME" `
    -var "MS_365_VMS_SSL_CACHE_PASSWORD=$env:MS_365_VMS_SSL_CACHE_PASSWORD" `
    -var "MS_365_VMS_SSL_PFX_PASSWORD=$env:MS_365_VMS_SSL_PFX_PASSWORD" `
    -var "MS_365_VMS_SHARED_SOURCE_UNC=$env:MS_365_VMS_SHARED_SOURCE_UNC" `
    -var "MS_365_VMS_SHARED_SOURCE_USERNAME=$env:MS_365_VMS_SHARED_SOURCE_USERNAME" `
    -var "MS_365_VMS_SHARED_SOURCE_PASSWORD=$env:MS_365_VMS_SHARED_SOURCE_PASSWORD" `
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
~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0/shared-variables-ignore-soft.sh
MS_365_VMS_STACK_TYPE_ID="win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-wp-tf0";
MS_365_VMS_STACK_INSTANCE_ID=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-dev00";
MS_365_VMS_DNS_PREFIX=$MS_365_VMS_PROJECT_PREFIX"dev-06-";
MS_365_VMS_WIN2022_AD_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_AD_IMAGE_NAME"
MS_365_VMS_WIN2022_SQL2022_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_SQL2022_IMAGE_NAME"
MS_365_VMS_WIN2022_WEB_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_WEB_IMAGE_NAME"
MS_365_VMS_WIN2022_FILES_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_SOE_IMAGE_NAME"
MS_365_VMS_WIN2022_WP_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_WP_IMAGE_NAME"
cd ~/projects/ms-365-vms/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0;
sudo rm -rf terraform.tfstate.d;
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2022_AD_IMAGE_ID=$MS_365_VMS_WIN2022_AD_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_AD_VM_SIZE=$MS_365_VMS_WIN2022_AD_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_SQL2022_IMAGE_ID=$MS_365_VMS_WIN2022_SQL2022_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_SQL2022_VM_SIZE=$MS_365_VMS_WIN2022_SQL2022_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_WEB_IMAGE_ID=$MS_365_VMS_WIN2022_WEB_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_WEB_VM_SIZE=$MS_365_VMS_WIN2022_WEB_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_FILES_IMAGE_ID=$MS_365_VMS_WIN2022_FILES_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_FILES_VM_SIZE=$MS_365_VMS_WIN2022_FILES_VM_SIZE" \
    -var "MS_365_VMS_WIN2022_WP_IMAGE_ID=$MS_365_VMS_WIN2022_WP_IMAGE_ID" \
    -var "MS_365_VMS_WIN2022_WP_VM_SIZE=$MS_365_VMS_WIN2022_WP_VM_SIZE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_DNS_PREFIX=$MS_365_VMS_DNS_PREFIX" \
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
    -var "CRM_MONITORING_SERVICE_PASSWORD=$CRM_MONITORING_SERVICE_PASSWORD" \
    -var "MS_365_VMS_SSL_CACHE_UNC=$MS_365_VMS_SSL_CACHE_UNC" \
    -var "MS_365_VMS_SSL_CACHE_USERNAME=$MS_365_VMS_SSL_CACHE_USERNAME" \
    -var "MS_365_VMS_SSL_CACHE_PASSWORD=$MS_365_VMS_SSL_CACHE_PASSWORD" \
    -var "MS_365_VMS_SSL_PFX_PASSWORD=$MS_365_VMS_SSL_PFX_PASSWORD" \
    -var "MS_365_VMS_SHARED_SOURCE_UNC=$MS_365_VMS_SHARED_SOURCE_UNC" \
    -var "MS_365_VMS_SHARED_SOURCE_USERNAME=$MS_365_VMS_SHARED_SOURCE_USERNAME" \
    -var "MS_365_VMS_SHARED_SOURCE_PASSWORD=$MS_365_VMS_SHARED_SOURCE_PASSWORD" \
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
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2022_ad_crm-win2022_sql2022-win2022_web-win2022_files-win2022_wp-terraform0 hashicorp/terraform:0.11.15 taint -module=DB00 azurerm_virtual_machine.main
```
