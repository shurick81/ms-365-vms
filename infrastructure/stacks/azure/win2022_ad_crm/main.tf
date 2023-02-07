variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_TENANT_ID" {}
variable "MS_365_VMS_LOCATION" {}
variable "MS_365_VMS_IMAGE_RG_NAME" {}
variable "MS_365_VMS_WIN2022_AD_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_AD_VM_SIZE" {}
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

terraform {
  required_providers {
    azurerm = {
      version = "=3.42.0"
    }
  }
}

provider "azurerm" {
  subscription_id               = var.ARM_SUBSCRIPTION_ID
  client_id                     = var.ARM_CLIENT_ID
  client_secret                 = var.ARM_CLIENT_SECRET
  tenant_id                     = var.ARM_TENANT_ID
  features {}
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
  address_prefixes      = ["10.0.1.0/24"]
}

module "AD00" {
  source                              = "./../machines/vm-ad-crm"
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
