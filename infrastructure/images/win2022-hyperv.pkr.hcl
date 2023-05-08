variable "box_name" {
  type    = string
  default = "${env("MS_365_VMS_IMAGE_NAME")}"
}

variable "client_id" {
  type    = string
  default = "${env("ARM_CLIENT_ID")}"
}

variable "client_secret" {
  type    = string
  default = "${env("ARM_CLIENT_SECRET")}"
}

variable "location" {
  type    = string
  default = "${env("MS_365_VMS_LOCATION")}"
}

variable "managed_image_resource_group_name" {
  type    = string
  default = "${env("MS_365_VMS_IMAGE_RG_NAME")}"
}

variable "subscription_id" {
  type    = string
  default = "${env("ARM_SUBSCRIPTION_ID")}"
}

variable "tenant_id" {
  type    = string
  default = "${env("ARM_TENANT_ID")}"
}

variable "vm_name" {
  type    = string
  default = "${env("MS_365_VMS_PACKER_VM_NAME")}"
}

variable "vm_size" {
  type    = string
  default = "${env("MS_365_VMS_VM_SIZE")}"
}

source "azure-arm" "azure00" {
  client_id                          = "${var.client_id}"
  client_secret                      = "${var.client_secret}"
  communicator                       = "winrm"
  image_offer                        = "WindowsServer"
  image_publisher                    = "MicrosoftWindowsServer"
  image_sku                          = "2022-Datacenter-smalldisk"
  image_version                      = "latest"
  location                           = "${var.location}"
  managed_image_name                 = "${var.box_name}"
  managed_image_resource_group_name  = "${var.managed_image_resource_group_name}"
  managed_image_storage_account_type = "Standard_LRS"
  os_type                            = "Windows"
  subscription_id                    = "${var.subscription_id}"
  temp_compute_name                  = "${var.vm_name}"
  tenant_id                          = "${var.tenant_id}"
  vm_size                            = "${var.vm_size}"
  winrm_insecure                     = "true"
  winrm_timeout                      = "30m"
  winrm_use_ssl                      = "true"
  winrm_username                     = "packer"
}

build {
  sources = ["source.azure-arm.azure00"]

  provisioner "powershell" {
    script = "winrm.ps1"
  }

  provisioner "powershell" {
    script = "PackageManagementProviderResource.ps1"
  }

  provisioner "powershell" {
    script = "basepsmodules.ps1"
  }

  provisioner "powershell" {
    script = "hyperv-bin.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "powershell" {
    script = "azure/sysprep.ps1"
  }

}
