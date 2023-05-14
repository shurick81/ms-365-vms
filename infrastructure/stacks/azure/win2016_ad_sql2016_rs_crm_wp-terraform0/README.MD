# Set variables

Review variable values in `.\shared.variables.ps1`.

# Build images

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2016_ad_sql2016_rs_crm_wp-terraform0\shared-variables.ps1
cd C:\projects\ms-365-vms\infrastructure\images
docker run --rm -v ${pwd}:/workplace -w /workplace `
    -e ARM_CLIENT_ID=$env:ARM_CLIENT_ID `
    -e ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET `
    -e ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID `
    -e ARM_TENANT_ID=$env:ARM_TENANT_ID `
    -e MS_365_VMS_VM_SIZE=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_VM_SIZE `
    -e MS_365_VMS_IMAGE_NAME=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_NAME `
    -e MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION `
    -e MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME `
    -e MS_365_VMS_PACKER_VM_NAME=$($env:MS_365_VMS_VM_NAME_SPEC.Replace("%s",(Get-Date -Format "ddHHmmss"))) `
    hashicorp/packer:1.8.7 `
    build -only azure-arm win2016-ad-sql2016-rs-crm-wp.json
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0/shared-variables.sh
cd ~/projects/ms-365-vms/infrastructure/images
docker run --rm -v $(pwd):/workplace -w /workplace \
    -e ARM_CLIENT_ID=$ARM_CLIENT_ID \
    -e ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET \
    -e ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID \
    -e ARM_TENANT_ID=$ARM_TENANT_ID \
    -e MS_365_VMS_VM_SIZE=$MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_VM_SIZE \
    -e MS_365_VMS_IMAGE_NAME=$MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_NAME \
    -e MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION \
    -e MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME \
    -e MS_365_VMS_PACKER_VM_NAME=${MS_365_VMS_VM_NAME_SPEC//%s/$(date '+%d%H%M%S')} \
    hashicorp/packer:1.8.7 \
    build -only azure-arm win2016-ad-sql2016-rs-crm-wp.json
```

# Provisioning stacks

```PowerShell
C:\projects\ms-365-vms\infrastructure\stacks\azure\win2016_ad_sql2016_rs_crm_wp-terraform0\shared-variables.ps1
$env:MS_365_VMS_STACK_TYPE_ID = "win2016_ad_sql2016_rs_crm_wp-terraform0";
$env:MS_365_VMS_STACK_INSTANCE_ID = $env:MS_365_VMS_PROJECT_PREFIX + $env:MS_365_VMS_STACK_TYPE_ID + "-dev-00";
$env:MS_365_VMS_DNS_PREFIX = $env:MS_365_VMS_PROJECT_PREFIX + "crm-1" + "-00-";
$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID = "/subscriptions/$env:ARM_SUBSCRIPTION_ID/resourceGroups/$env:MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_NAME"
cd c:\projects\ms-365-vms\infrastructure\stacks\azure\win2016_ad_sql2016_rs_crm_wp-terraform0;
Remove-Item terraform.tfstate.d -Recurse
Start-Sleep 5;
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $env:MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID" `
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_DNS_PREFIX=$env:MS_365_VMS_DNS_PREFIX" `
    -var "MS_365_VMS_DOMAIN_NAME=$env:MS_365_VMS_DOMAIN_NAME" `
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
    -var "MS_365_VMS_DYNAMICS_CRM_BASE=$env:MS_365_VMS_DYNAMICS_CRM_BASE" `
    -var "MS_365_VMS_DYNAMICS_CRM_UPDATE=$env:MS_365_VMS_DYNAMICS_CRM_UPDATE" `
    -var "MS_365_VMS_DYNAMICS_CRM_RE_UPDATE=$env:MS_365_VMS_DYNAMICS_CRM_RE_UPDATE" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE=$env:MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION" `
    -var "MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION=$env:MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION";
```

```bash
~/projects/ms-365-vms/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0/shared-variables.ps1
MS_365_VMS_STACK_TYPE_ID="win2016_ad_sql2016_rs_crm_wp-terraform0";
MS_365_VMS_STACK_INSTANCE_ID=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-dev-00";
MS_365_VMS_DNS_PREFIX=$MS_365_VMS_PROJECT_PREFIX"crm-1-00-";
MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_NAME"
cd ~/projects/ms-365-vms/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0;
sudo rm -rf terraform.tfstate.d;
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 init
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 workspace new $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 workspace select $MS_365_VMS_STACK_INSTANCE_ID
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 apply -auto-approve \
    -var "ARM_CLIENT_ID=$ARM_CLIENT_ID" \
    -var "ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" \
    -var "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" \
    -var "ARM_TENANT_ID=$ARM_TENANT_ID" \
    -var "MS_365_VMS_LOCATION=$MS_365_VMS_LOCATION" \
    -var "MS_365_VMS_IMAGE_RG_NAME=$MS_365_VMS_IMAGE_RG_NAME" \
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID=$MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID" \
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE=$MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE" \
    -var "MS_365_VMS_VM_NAME_SPEC=$MS_365_VMS_VM_NAME_SPEC" \
    -var "MS_365_VMS_DNS_PREFIX=$MS_365_VMS_DNS_PREFIX" \
    -var "MS_365_VMS_DOMAIN_NAME=$MS_365_VMS_DOMAIN_NAME" \
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
    -var "MS_365_VMS_DYNAMICS_CRM_BASE=$MS_365_VMS_DYNAMICS_CRM_BASE" \
    -var "MS_365_VMS_DYNAMICS_CRM_UPDATE=$MS_365_VMS_DYNAMICS_CRM_UPDATE" \
    -var "MS_365_VMS_DYNAMICS_CRM_RE_UPDATE=$MS_365_VMS_DYNAMICS_CRM_RE_UPDATE" \
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE=$MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE" \
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME=$MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME" \
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL=$MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL" \
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION=$MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION" \
    -var "MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION=$MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION";
```

```PowerShell
docker run --rm -v ${pwd}/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 destroy -target module.SRV00.azurerm_virtual_machine.main -auto-approve `
    -var "ARM_CLIENT_ID=$env:ARM_CLIENT_ID" `
    -var "ARM_CLIENT_SECRET=$env:ARM_CLIENT_SECRET" `
    -var "ARM_SUBSCRIPTION_ID=$env:ARM_SUBSCRIPTION_ID" `
    -var "ARM_TENANT_ID=$env:ARM_TENANT_ID" `
    -var "MS_365_VMS_LOCATION=$env:MS_365_VMS_LOCATION" `
    -var "MS_365_VMS_IMAGE_RG_NAME=$env:MS_365_VMS_IMAGE_RG_NAME" `
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_IMAGE_ID" `
    -var "MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE=$env:MS_365_VMS_WIN2016_AD_SQL2016_RS_CRM_WP_VM_SIZE" `
    -var "MS_365_VMS_VM_NAME_SPEC=$env:MS_365_VMS_VM_NAME_SPEC" `
    -var "MS_365_VMS_DNS_PREFIX=$env:MS_365_VMS_DNS_PREFIX" `
    -var "MS_365_VMS_DOMAIN_NAME=$env:MS_365_VMS_DOMAIN_NAME" `
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
    -var "MS_365_VMS_DYNAMICS_CRM_BASE=$env:MS_365_VMS_DYNAMICS_CRM_BASE" `
    -var "MS_365_VMS_DYNAMICS_CRM_UPDATE=$env:MS_365_VMS_DYNAMICS_CRM_UPDATE" `
    -var "MS_365_VMS_DYNAMICS_CRM_RE_UPDATE=$env:MS_365_VMS_DYNAMICS_CRM_RE_UPDATE" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE=$env:MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL" `
    -var "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION=$env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION" `
    -var "MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION=$env:MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION";
```

```PowerShell
docker run -it --rm mcr.microsoft.com/azure-cli:2.48.1 /bin/bash -c "az login --service-principal -u $env:ARM_CLIENT_ID -p $env:ARM_CLIENT_SECRET --tenant $env:ARM_TENANT_ID; `
    az group delete --subscription $env:ARM_SUBSCRIPTION_ID -n $env:MS_365_VMS_STACK_INSTANCE_ID -y"
```

```bash
docker run --rm -v $(pwd)/../../../..:/workplace -w /workplace/infrastructure/stacks/azure/win2016_ad_sql2016_rs_crm_wp-terraform0 hashicorp/terraform:0.11.15 taint -module=SRV00 azurerm_virtual_machine.main
```
