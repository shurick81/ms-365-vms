variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_TENANT_ID" {}
variable "MS_365_VMS_LOCATION" {}
variable "MS_365_VMS_IMAGE_RG_NAME" {}
variable "MS_365_VMS_WIN2022_AD_SQL2022_RS2019_CRM_WP_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_AD_SQL2022_RS2019_CRM_WP_VM_SIZE" {}
variable "MS_365_VMS_VM_NAME_SPEC" {}
variable "VM_ADMIN_USERNAME" {
  default = "custom3094857"
}
variable "MS_365_VMS_DNS_PREFIX" {}
variable "MS_365_VMS_DOMAIN_NAME" {}
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
variable "MS_365_VMS_DYNAMICS_CRM_BASE" {}
variable "MS_365_VMS_DYNAMICS_CRM_UPDATE" {}
variable "MS_365_VMS_DYNAMICS_CRM_RE_UPDATE" {}
variable "MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE" {}
variable "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME" {}
variable "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL" {}
variable "MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION" {}
variable "MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION" {}

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
  resource_group_name = "${azurerm_resource_group.environment.name}"

}

# Create subnet
resource "azurerm_subnet" "mainterraformsubnet" {
  name                  = "mainSubnet"
  resource_group_name   = "${azurerm_resource_group.environment.name}"
  virtual_network_name  = "${azurerm_virtual_network.mainterraformnetwork.name}"
  address_prefix        = "10.0.1.0/24"
}

module "SRV00" {
  source                                          = "./../machines/vm-ad-sql-rs-crm-wp-terraform0"
  environmentId                                   = "${terraform.workspace}"
  location                                        = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                               = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  database_instance                               = "${format(var.MS_365_VMS_VM_NAME_SPEC, "srv00")}\\SQLInstance01"
  rs_service_password                             = "${var.RS_SERVICE_PASSWORD}"
  crm_test_1_password                             = "${var.CRM_TEST_1_PASSWORD}"
  crm_test_2_password                             = "${var.CRM_TEST_2_PASSWORD}"
  install_password                            = "${var.CRM_INSTALL_PASSWORD}"
  crm_service_password                            = "${var.CRM_SERVICE_PASSWORD}"
  crm_deployment_service_password                 = "${var.CRM_DEPLOYMENT_SERVICE_PASSWORD}"
  crm_sandbox_service_password                    = "${var.CRM_SANDBOX_SERVICE_PASSWORD}"
  crm_vss_writer_password                         = "${var.CRM_VSS_WRITER_PASSWORD}"
  crm_async_service_password                      = "${var.CRM_ASYNC_SERVICE_PASSWORD}"
  crm_monitoring_service_password                 = "${var.CRM_MONITORING_SERVICE_PASSWORD}"
  vm_resource_group_name                          = "${azurerm_resource_group.environment.name}"
  main_subnet_id                                  = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                                        = "${var.MS_365_VMS_WIN2022_AD_SQL2022_RS2019_CRM_WP_IMAGE_ID}"
  vm_name                                         = "${format(var.MS_365_VMS_VM_NAME_SPEC, "srv00")}"
  vm_size                                         = "${var.MS_365_VMS_WIN2022_AD_SQL2022_RS2019_CRM_WP_VM_SIZE}"
  vm_domain_name_label                            = "${var.MS_365_VMS_DNS_PREFIX}${format(var.MS_365_VMS_VM_NAME_SPEC, "srv00")}"
  ms_365_vms_domain_name                          = "${var.MS_365_VMS_DOMAIN_NAME}"
  ms_365_vms_ssl_cache_unc                        = "${var.MS_365_VMS_SSL_CACHE_UNC}"
  ms_365_vms_ssl_cache_username                   = "${var.MS_365_VMS_SSL_CACHE_USERNAME}"
  ms_365_vms_ssl_cache_password                   = "${var.MS_365_VMS_SSL_CACHE_PASSWORD}"
  ms_365_vms_ssl_pfx_password                     = "${var.MS_365_VMS_SSL_PFX_PASSWORD}"
  ms_365_vms_dynamics_crm_base                    = "${var.MS_365_VMS_DYNAMICS_CRM_BASE}"
  ms_365_vms_dynamics_crm_update                  = "${var.MS_365_VMS_DYNAMICS_CRM_UPDATE}"
  ms_365_vms_dynamics_crm_re_update               = "${var.MS_365_VMS_DYNAMICS_CRM_RE_UPDATE}"
  ms_365_vms_dynamics_crm_base_iso_currency_code  = "${var.MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE}"
  ms_365_vms_dynamics_crm_base_currency_name      = "${var.MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME}"
  ms_365_vms_dynamics_crm_base_currency_symbol    = "${var.MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL}"
  ms_365_vms_dynamics_crm_base_currency_precision = "${var.MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION}"
  ms_365_vms_dynamics_crm_organization_collation  = "${var.MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION}"
  dependencies                                    = []
}
