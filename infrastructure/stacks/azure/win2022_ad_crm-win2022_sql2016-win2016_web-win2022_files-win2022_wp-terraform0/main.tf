variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_TENANT_ID" {}
variable "MS_365_VMS_LOCATION" {}
variable "MS_365_VMS_IMAGE_RG_NAME" {}
variable "MS_365_VMS_WIN2022_AD_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_AD_VM_SIZE" {}
variable "MS_365_VMS_WIN2022_SQL2016_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_SQL2016_VM_SIZE" {}
variable "MS_365_VMS_WIN2016_WEB_IMAGE_ID" {}
variable "MS_365_VMS_WIN2016_WEB_VM_SIZE" {}
variable "MS_365_VMS_WIN2022_FILES_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_FILES_VM_SIZE" {}
variable "MS_365_VMS_WIN2022_WP_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_WP_VM_SIZE" {}
variable "MS_365_VMS_VM_NAME_SPEC" {}
variable "VM_ADMIN_USERNAME" {
  default = "custom3094857"
}
variable "MS_365_VMS_DNS_PREFIX" {}
variable "MS_365_VMS_DOMAIN_NAME" {}
variable "MS_365_VMS_VM_ADMIN_PASSWORD" {}
variable "MS_365_VMS_DOMAIN_ADMIN_PASSWORD" {}
variable "RS_SERVICE_PASSWORD" {}
variable "CRM_TEST_1_PASSWORD" {}
variable "CRM_TEST_2_PASSWORD" {}
variable "CRM_INSTALL_PASSWORD" {}
variable "CRM_SERVICE_PASSWORD" {}
variable "CRM_DEPLOYMENT_SERVICE_PASSWORD" {}
variable "CRM_SANDBOX_SERVICE_PASSWORD" {}
variable "CRM_VSS_WRITER_PASSWORD" {}
variable "CRM_ASYNC_SERVICE_PASSWORD" {}
variable "CRM_MONITORING_SERVICE_PASSWORD" {}
variable "MS_365_VMS_SSL_CACHE_UNC" {}
variable "MS_365_VMS_SSL_CACHE_USERNAME" {}
variable "MS_365_VMS_SSL_CACHE_PASSWORD" {}
variable "MS_365_VMS_SSL_PFX_PASSWORD" {}
variable "MS_365_VMS_SHARED_SOURCE_UNC" {}
variable "MS_365_VMS_SHARED_SOURCE_USERNAME" {}
variable "MS_365_VMS_SHARED_SOURCE_PASSWORD" {}
variable "MS_365_VMS_PIPELINE_PROVIDER" {
  default = "None"
}
variable "MS_365_VMS_PIPELINE_URL" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_TOKEN" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_STACK_LABEL" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_ACCOUNT_UIID" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_REPOSITORY_UIID" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_RUNNER_UIID" {
  default = ""
}
variable "MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID" {
  default = ""
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  version         = "=1.33.0"
  subscription_id = "${var.ARM_SUBSCRIPTION_ID}"
  client_id       = "${var.ARM_CLIENT_ID}"
  client_secret   = "${var.ARM_CLIENT_SECRET}"
  tenant_id       = "${var.ARM_TENANT_ID}"
  #features {}
}

resource "azurerm_resource_group" "environment" {
  name     = "${terraform.workspace}"
  location = "${var.MS_365_VMS_LOCATION}"
}

resource "azurerm_virtual_network" "mainterraformnetwork" {
  name                = "common"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.MS_365_VMS_LOCATION}"
  dns_servers         = ["10.0.1.254"]
  resource_group_name = "${azurerm_resource_group.environment.name}"

}

# Create subnet
resource "azurerm_subnet" "mainterraformsubnet" {
  name                  = "mainSubnet"
  resource_group_name   = "${azurerm_resource_group.environment.name}"
  virtual_network_name  = "${azurerm_virtual_network.mainterraformnetwork.name}"
  address_prefix        = "10.0.1.0/24"
}

module "AD00" {
  source                              = "./../machines/vm-ad-crm-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  rs_service_password                 = "${var.RS_SERVICE_PASSWORD}"
  crm_test_1_password                 = "${var.CRM_TEST_1_PASSWORD}"
  crm_test_2_password                 = "${var.CRM_TEST_2_PASSWORD}"
  crm_install_password                = "${var.CRM_INSTALL_PASSWORD}"
  crm_service_password                = "${var.CRM_SERVICE_PASSWORD}"
  crm_deployment_service_password     = "${var.CRM_DEPLOYMENT_SERVICE_PASSWORD}"
  crm_sandbox_service_password        = "${var.CRM_SANDBOX_SERVICE_PASSWORD}"
  crm_vss_writer_password             = "${var.CRM_VSS_WRITER_PASSWORD}"
  crm_async_service_password          = "${var.CRM_ASYNC_SERVICE_PASSWORD}"
  crm_monitoring_service_password     = "${var.CRM_MONITORING_SERVICE_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_AD_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "ad00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_AD_VM_SIZE}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  dependencies                        = []
}

module "DB00" {
  source                              = "./../machines/vm-sql-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  domain_admin_password               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_SQL2016_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "db00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_SQL2016_VM_SIZE}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  local_admins                        = "${var.MS_365_VMS_DOMAIN_NAME}\\CRM Administrators 00,${var.MS_365_VMS_DOMAIN_NAME}\\_crmdplsrv"
  dependencies = [
    "${module.AD00.depended_on}"
  ]
}

module "SERVER00" {
  source                              = "./../machines/vm-web-base-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  domain_admin_password               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2016_WEB_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "server00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2016_WEB_VM_SIZE}"
  os_disk_size_gb                     = "127"
  vm_domain_name_label                = "${var.MS_365_VMS_DNS_PREFIX}${format(var.MS_365_VMS_VM_NAME_SPEC, "server00")}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  ms_365_vms_ssl_cache_unc            = "${var.MS_365_VMS_SSL_CACHE_UNC}"
  ms_365_vms_ssl_cache_username       = "${var.MS_365_VMS_SSL_CACHE_USERNAME}"
  ms_365_vms_ssl_cache_password       = "${var.MS_365_VMS_SSL_CACHE_PASSWORD}"
  ms_365_vms_ssl_pfx_password         = "${var.MS_365_VMS_SSL_PFX_PASSWORD}"
  local_admins                        = "${var.MS_365_VMS_DOMAIN_NAME}\\CRM Administrators 00"
  https_ports                         = "443"
  dependencies = [
    "${module.AD00.depended_on}"
  ]
}

module "FILES00" {
  source                              = "./../machines/vm-files-base-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  domain_admin_password               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_FILES_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "files00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_FILES_VM_SIZE}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  local_admins                        = "${var.MS_365_VMS_DOMAIN_NAME}\\CRM Administrators 00"
  file_share_full_access_identities   = "BUILTIN\\Administrators,${element( split( ".", var.MS_365_VMS_DOMAIN_NAME), 0)}\\${format(var.MS_365_VMS_VM_NAME_SPEC, "db00")}$"
  ms_365_vms_shared_source_unc         = "${var.MS_365_VMS_SHARED_SOURCE_UNC}"
  ms_365_vms_shared_source_username    = "${var.MS_365_VMS_SHARED_SOURCE_USERNAME}"
  target_files_path                   = "f:\\common-files\\Shared_Files"
  ms_365_vms_shared_source_password   = "${var.MS_365_VMS_SHARED_SOURCE_PASSWORD}"
  dependencies = [
    "${module.DB00.depended_on}"
  ]
}

module "WP00" {
  source                              = "./../machines/vm-wp-base-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  domain_admin_password               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_WP_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "wp00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_WP_VM_SIZE}"
  vm_domain_name_label                = "${var.MS_365_VMS_DNS_PREFIX}${format(var.MS_365_VMS_VM_NAME_SPEC, "wp00")}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  local_admins                        = "${var.MS_365_VMS_DOMAIN_NAME}\\CRM Administrators 00"
  ms_365_vms_pipeline_provider        = "${var.MS_365_VMS_PIPELINE_PROVIDER}"
  ms_365_vms_pipeline_url             = "${var.MS_365_VMS_PIPELINE_URL}"
  ms_365_vms_pipeline_token           = "${var.MS_365_VMS_PIPELINE_TOKEN}"
  ms_365_vms_pipeline_labels          = "${var.MS_365_VMS_PIPELINE_STACK_LABEL},${var.MS_365_VMS_PIPELINE_STACK_LABEL}-wp00,wp00"
  ms_365_vms_pipeline_accountUuid     = "${var.MS_365_VMS_PIPELINE_ACCOUNT_UIID}"
  ms_365_vms_pipeline_repositoryUuid  = "${var.MS_365_VMS_PIPELINE_REPOSITORY_UIID}"
  ms_365_vms_pipeline_runnerUuid      = "${var.MS_365_VMS_PIPELINE_RUNNER_UIID}"
  ms_365_vms_pipeline_OAuthClientId   = "${var.MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID}"
  dependencies = [
    "${module.AD00.depended_on}"
  ]
}
