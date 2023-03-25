ARM_CLIENT_ID="531adb66-98a5-4e6b-b407-b1961a2794e1";
ARM_CLIENT_SECRET="xxxx";
ARM_SUBSCRIPTION_ID="d7c7a3af-f74f-4007-845c-dcacef601c53";
ARM_TENANT_ID="8b87af7d-8647-4dc7-8df4-5f69a2011bb5";
MS_365_VMS_LOCATION="westeurope";
MS_365_VMS_IMAGE_RG_NAME="CommonRGWestEurope";
MS_365_VMS_PROJECT_PREFIX="ms-365-vms-";
MS_365_VMS_VM_NAME_SPEC="swaz%s";
MS_365_VMS_WIN2022_AD_IMAGE_VM_SIZE="Standard_D2s_v3";
MS_365_VMS_WIN2022_AD_IMAGE_NAME=$MS_365_VMS_PROJECT_PREFIX"win2022-ad-$MS_365_VMS_LOCATION-000000";
MS_365_VMS_WIN2022_AD_VM_SIZE="Standard_B2s";
MS_365_VMS_DOMAIN_NAME="c0nt0s00.local";
MS_365_VMS_DOMAIN_ADMIN_PASSWORD="xxxx";
RS_SERVICE_PASSWORD="xxxx";
CRM_TEST_1_PASSWORD="xxxx";
CRM_TEST_2_PASSWORD="xxxx";
CRM_INSTALL_PASSWORD="xxxx";
CRM_SERVICE_PASSWORD="xxxx";
CRM_DEPLOYMENT_SERVICE_PASSWORD="xxxx";
CRM_SANDBOX_SERVICE_PASSWORD="xxxx";
CRM_VSS_WRITER_PASSWORD="xxxx";
CRM_ASYNC_SERVICE_PASSWORD="xxxx";
CRM_MONITORING_SERVICE_PASSWORD="xxxx";

MS_365_VMS_STACK_TYPE_ID="win2022_ad_crm";
MS_365_VMS_STACK_INSTANCE_ID=$MS_365_VMS_PROJECT_PREFIX$MS_365_VMS_STACK_TYPE_ID"-dev-00";
MS_365_VMS_WIN2022_AD_IMAGE_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$MS_365_VMS_IMAGE_RG_NAME/providers/Microsoft.Compute/images/$MS_365_VMS_WIN2022_AD_IMAGE_NAME"
