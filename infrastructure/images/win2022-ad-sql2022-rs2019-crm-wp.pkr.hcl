
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

variable "hyperv_switch_name" {
  type    = string
  default = "${env("MS_365_VMS_HYPERV_SWITCH")}"
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
  image_sku                          = "2022-Datacenter"
  image_version                      = "latest"
  location                           = "${var.location}"
  managed_image_name                 = "${var.box_name}"
  managed_image_resource_group_name  = "${var.managed_image_resource_group_name}"
  managed_image_storage_account_type = "Standard_LRS"
  os_type                            = "Windows"
  polling_duration_timeout           = "40m"
  subscription_id                    = "${var.subscription_id}"
  temp_compute_name                  = "${var.vm_name}"
  tenant_id                          = "${var.tenant_id}"
  vm_size                            = "${var.vm_size}"
  winrm_insecure                     = "true"
  winrm_timeout                      = "30m"
  winrm_use_ssl                      = "true"
  winrm_username                     = "packer"
}

source "hyperv-iso" "win2022-ad-sql2022-rs2019-crm-wp-000000" {
  communicator     = "winrm"
  cpus             = 4
  disk_size        = 102400
  floppy_files     = ["autounattend/hyper-v/win2022/Autounattend.xml", "HyperV/hyperv-init.ps1", "sysprep.bat", "autounattend_sysprep.xml"]
  headless         = true
  iso_checksum     = "3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_url          = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  memory           = 4096
  shutdown_command = "a:/sysprep.bat"
  switch_name      = "${var.hyperv_switch_name}"
  winrm_password   = "Fractalsol365"
  winrm_timeout    = "2h"
  winrm_username   = "packer"
}

source "virtualbox-iso" "win2022-ad-sql2022-rs2019-crm-wp-000000" {
  communicator         = "winrm"
  disk_size            = 102400
  floppy_files         = ["autounattend/virtualbox/win2022/Autounattend.xml", "winrm.ps1", "sysprep.bat", "autounattend_sysprep.xml"]
  guest_additions_mode = "attach"
  guest_os_type        = "Windows2016_64"
  headless             = true
  iso_checksum         = "3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_url              = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
  shutdown_command     = "a:/sysprep.bat"
  vboxmanage           = [["modifyvm", "{{ .Name }}", "--memory", "4096"], ["modifyvm", "{{ .Name }}", "--cpus", "4"]]
  winrm_password       = "Fractalsol365"
  winrm_timeout        = "2h"
  winrm_username       = "packer"
}

build {
  sources = ["source.azure-arm.azure00", "source.hyperv-iso.win2022-ad-sql2022-rs2019-crm-wp-000000", "source.virtualbox-iso.win2022-ad-sql2022-rs2019-crm-wp-000000"]

  provisioner "powershell" {
    only   = ["virtualbox-iso.win2022-ad-sql2022-rs2019-crm-wp-000000"]
    script = "VirtualBox/installadditions.ps1"
  }

  provisioner "powershell" {
    only   = ["hyperv-iso.win2022-ad-sql2022-rs2019-crm-wp-000000"]
    script = "HyperV/integration.ps1"
  }

  provisioner "powershell" {
    only   = ["virtualbox-iso.win2022-ad-sql2022-rs2019-crm-wp-000000", "hyperv-iso.win2022-ad-sql2022-rs2019-crm-wp-000000"]
    script = "rdpenable.ps1"
  }

  provisioner "powershell" {
    only   = ["azure-arm.azure00"]
    script = "winrm.ps1"
  }

  provisioner "powershell" {
    script = "PackageManagementProviderResource.ps1"
  }

  provisioner "powershell" {
    script = "basepsmodules.ps1"
  }

  provisioner "powershell" {
    script = "domainclientpsmodules.ps1"
  }

  provisioner "powershell" {
    script = "adpsmodules.ps1"
  }

  provisioner "powershell" {
    script = "sqlpsmodules.ps1"
  }

  provisioner "powershell" {
    script = "dynamicspsmodules.ps1"
  }

  provisioner "powershell" {
    script = "wp-ps-modules.ps1"
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "powershell" {
    script = "nodefender.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "Install-SSLTools.ps1"
  }

  provisioner "powershell" {
    script = "adbin.ps1"
  }

  provisioner "powershell" {
    script = "sql2022-media.ps1"
  }

  provisioner "powershell" {
    script = "sql2022-bin.ps1"
  }

  provisioner "powershell" {
    environment_vars = ["VMDEVOPSSTARTER_NODSCTEST=TRUE"]
    script           = "sql2022-media-clean.ps1"
  }

  provisioner "powershell" {
    script = "sql2019-media.ps1"
  }

  provisioner "powershell" {
    script = "sql2022-bin-rs.ps1"
  }

  provisioner "powershell" {
    environment_vars = ["VMDEVOPSSTARTER_NODSCTEST=TRUE"]
    script           = "sql2019-media-clean.ps1"
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    script = "dynamicsprebin.ps1"
  }

  provisioner "powershell" {
    inline = ["Install-Dynamics365Prerequisite;"]
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    script = "dev-media-2022.ps1"
  }

  provisioner "powershell" {
    environment_vars = ["VMDEVOPSSTARTER_NODSCTEST=TRUE"]
    script           = "dev-bin-1.ps1"
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    script = "dev-bin-1.ps1"
  }

  provisioner "windows-restart" {
  }

  provisioner "powershell" {
    script = "dev-media-clean.ps1"
  }

  provisioner "powershell" {
    script = "dev-bin-2.ps1"
  }

  provisioner "powershell" {
    script = "Setup-WP.ps1"
  }

  provisioner "powershell" {
    script = "xcred-server.ps1"
  }

  provisioner "windows-restart" {
    restart_timeout = "30m"
  }

  provisioner "powershell" {
    script = "waitforcpucalm.ps1"
  }

  provisioner "powershell" {
    only   = ["azure-arm.azure00"]
    script = "azure/sysprep_full.ps1"
  }

  post-processor "vagrant" {
    only   = ["virtualbox-iso.win2022-ad-sql2022-rs2019-crm-wp-000000", "hyperv-iso.win2022-ad-sql2022-rs2019-crm-wp-000000"]
    output = "${var.box_name}.box"
  }
}
