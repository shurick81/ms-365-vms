variable "ARM_CLIENT_ID" {}
variable "ARM_CLIENT_SECRET" {}
variable "ARM_SUBSCRIPTION_ID" {}
variable "ARM_TENANT_ID" {}
variable "MS_365_VMS_LOCATION" {}
variable "MS_365_VMS_IMAGE_RG_NAME" {}
variable "MS_365_VMS_WIN2022_WP_IMAGE_ID" {}
variable "MS_365_VMS_WIN2022_WP_VM_SIZE" {}
variable "MS_365_VMS_VM_NAME_SPEC" {}
variable "VM_ADMIN_USERNAME" {
  default = "custom3094857"
}
variable "MS_365_VMS_VM_ADMIN_PASSWORD" {}
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
variable "MS_365_VMS_PIPELINE_RUNNER_VERSION" {
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
  resource_group_name = "${azurerm_resource_group.environment.name}"

}

# Create subnet
resource "azurerm_subnet" "mainterraformsubnet" {
  name                  = "mainSubnet"
  resource_group_name   = "${azurerm_resource_group.environment.name}"
  virtual_network_name  = "${azurerm_virtual_network.mainterraformnetwork.name}"
  address_prefix        = "10.0.1.0/24"
}

module "WP00" {
  source                              = "./../machines/vm-wp-standalone-terraform0"
  environmentId                       = "${terraform.workspace}"
  location                            = "${var.MS_365_VMS_LOCATION}"
  vm_admin_username                   = "${var.VM_ADMIN_USERNAME}"
  vm_admin_password                   = "${var.MS_365_VMS_VM_ADMIN_PASSWORD}"
  vm_resource_group_name              = "${azurerm_resource_group.environment.name}"
  main_subnet_id                      = "${azurerm_subnet.mainterraformsubnet.id}"
  image_id                            = "${var.MS_365_VMS_WIN2022_WP_IMAGE_ID}"
  vm_name                             = "${format(var.MS_365_VMS_VM_NAME_SPEC, "wp00")}"
  vm_size                             = "${var.MS_365_VMS_WIN2022_WP_VM_SIZE}"
  ms_365_vms_pipeline_provider        = "${var.MS_365_VMS_PIPELINE_PROVIDER}"
  ms_365_vms_pipeline_url             = "${var.MS_365_VMS_PIPELINE_URL}"
  ms_365_vms_pipeline_token           = "${var.MS_365_VMS_PIPELINE_TOKEN}"
  ms_365_vms_pipeline_labels          = "${var.MS_365_VMS_PIPELINE_STACK_LABEL},${var.MS_365_VMS_PIPELINE_STACK_LABEL}-wp00,wp00"
  ms_365_vms_pipeline_accountUuid     = "${var.MS_365_VMS_PIPELINE_ACCOUNT_UIID}"
  ms_365_vms_pipeline_repositoryUuid  = "${var.MS_365_VMS_PIPELINE_REPOSITORY_UIID}"
  ms_365_vms_pipeline_runnerUuid      = "${var.MS_365_VMS_PIPELINE_RUNNER_UIID}"
  ms_365_vms_pipeline_OAuthClientId   = "${var.MS_365_VMS_PIPELINE_OAUTH_CLIENT_ID}"
  ms_365_vms_pipeline_runner_version  = "${var.MS_365_VMS_PIPELINE_RUNNER_VERSION}"
  dependencies = [
  ]
}
