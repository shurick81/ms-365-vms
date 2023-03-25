variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_TENANT_ID" {}
variable "MS_365_VMS_LOCATION" {}
variable "MS_365_VMS_IMAGE_RG_NAME" {}
variable "MS_365_VMS_WIN2022_AD_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_AD_VM_SIZE" {}
variable "MS_365_VMS_WIN2016_SQL2017_RS_IMAGE_ID" {}
variable "MS_365_VMS_WIN2016_SQL2017_RS_VM_SIZE" {}
variable "MS_365_VMS_VM_NAME_SPEC" {}
variable "VM_ADMIN_USERNAME" {
  default = "custom3094857"
}
variable "MS_365_VMS_DOMAIN_NAME" {}
variable "MS_365_VMS_VM_ADMIN_PASSWORD" {}
variable "MS_365_VMS_DOMAIN_ADMIN_PASSWORD" {}
variable "INSTALL_PASSWORD" {}
variable "RS_SERVICE_PASSWORD" {}

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
  source                              = "./../machines/vm-ad-rs-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  install_password                    = "${var.INSTALL_PASSWORD}"
  rs_service_password                 = "${var.RS_SERVICE_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_AD_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "ad00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_AD_VM_SIZE}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  dependencies                        = []
}

module "DB00" {
  source                              = "./../machines/vm-sql-rs-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  domain_admin_password               = "${var.MS_365_VMS_DOMAIN_ADMIN_PASSWORD}"
  install_password                    = "${var.INSTALL_PASSWORD}"
  rs_service_password                 = "${var.RS_SERVICE_PASSWORD}"
  database_instance                   = "${format(var.MS_365_VMS_VM_NAME_SPEC, "db00")}\\SQLInstance01"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2016_SQL2017_RS_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "db00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2016_SQL2017_RS_VM_SIZE}"
  ms_365_vms_domain_name              = "${var.MS_365_VMS_DOMAIN_NAME}"
  local_admins                        = "${var.MS_365_VMS_DOMAIN_NAME}\\_install,${var.MS_365_VMS_DOMAIN_NAME}\\_ssrs" #ssrs service need to access http
  dependencies = [
    "${module.AD00.depended_on}"
  ]
}
