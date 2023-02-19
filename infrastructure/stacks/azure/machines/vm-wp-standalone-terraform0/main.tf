variable "environmentId" {}
variable "location" {}
variable "vm_admin_username" {}
variable "vm_admin_password" {}
variable "vm_resource_group_name" {}
variable "main_subnet_id" {}
variable "image_id" {}
variable "vm_name" {}
variable "vm_size" {}
variable "ms_365_vms_pipeline_provider" {}
variable "ms_365_vms_pipeline_url" {}
variable "ms_365_vms_pipeline_token" {}
variable "ms_365_vms_pipeline_labels" {}
variable "dependencies" {
  type = "list"
}

# Workplace that is not a member of Windows domain

resource "null_resource" "dependency_getter" {
  provisioner "local-exec" {
    command = "echo ${length(var.dependencies)}"
  }
}

# Create public IPs
resource "azurerm_public_ip" "main" {
  name                = "${var.vm_name}-pip"
  location            = "${var.location}"
  resource_group_name = "${var.vm_resource_group_name}"
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "main" {
  name                = "${var.vm_name}-nsg"
  location            = "${var.location}"
  resource_group_name = "${var.vm_resource_group_name}"

  security_rule {
    name                       = "RDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM"
    priority                   = 310
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic01" {
  name                      = "${var.vm_name}-nic01"
  location                  = "${var.location}"
  resource_group_name       = "${var.vm_resource_group_name}"
  network_security_group_id = "${azurerm_network_security_group.main.id}"

  ip_configuration {
    name                          = "mainNicConfiguration"
    subnet_id                     = "${var.main_subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.main.id}"
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "main" {
  name                          = "${var.vm_name}"
  location                      = "${var.location}"
  resource_group_name           = "${var.vm_resource_group_name}"
  network_interface_ids         = ["${azurerm_network_interface.nic01.id}"]
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = true
  #license_type                  = "Windows_Server"

  storage_os_disk {
    name              = "${var.vm_name}-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "40"
  }

  storage_image_reference {
    id = "${var.image_id}"
  }

  os_profile {
    computer_name  = "${upper(var.vm_name)}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
    custom_data = "${base64encode("Param($RemoteHostName = \"${azurerm_public_ip.main.ip_address}\", $ComputerName = \"${var.vm_name}\", $WinRmPort = 5986) ${file("../vm-initiate.ps1")}")}"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true

    additional_unattend_config {
        pass = "oobeSystem"
        component = "Microsoft-Windows-Shell-Setup"
        setting_name = "AutoLogon"
        content = "<AutoLogon><Password><Value>${var.vm_admin_password}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.vm_admin_username}</Username></AutoLogon>"
    }
    #Unattend config is to enable basic auth in WinRM, required for the provisioner stage.
    additional_unattend_config {
        pass = "oobeSystem"
        component = "Microsoft-Windows-Shell-Setup"
        setting_name = "FirstLogonCommands"
        content = "${file("../FirstLogonCommands.xml")}"
    }
  }

  provisioner "remote-exec" {
    connection {
      user     = "${var.vm_admin_username}"
      password = "${var.vm_admin_password}"
      port     = 5986
      https    = true
      timeout  = "10m"

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
      #host = "${azurerm_public_ip.main.ip_address}"
    }

    inline = [
      "powershell.exe -command \"Resize-Partition -DriveLetter C -Size (Get-PartitionSupportedSize -DriveLetter C).SizeMax;\"",
    ]

    on_failure = "continue"
  }
  provisioner "file" {
    connection {
      user     = "${var.vm_admin_username}"
      password = "${var.vm_admin_password}"
      port     = 5986
      https    = true
      timeout  = "10m"

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
      #host = "${azurerm_public_ip.main.ip_address}"
    }

    source      = "./../../Install-PipelineAgent.ps1"
    destination = ".\\common\\Install-PipelineAgent.ps1"
  }

  provisioner "remote-exec" {
    connection {
      user     = "${var.vm_admin_username}"
      password = "${var.vm_admin_password}"
      port     = 5986
      https    = true
      timeout  = "10m"

      # NOTE: if you're using a real certificate, rather than a self-signed one, you'll want this set to `false`/to remove this.
      insecure = true
      #host = "${azurerm_public_ip.main.ip_address}"
    }

    inline = [
      "powershell.exe -command \"$env:MS_365_VMS_PIPELINE_PROVIDER = '${var.ms_365_vms_pipeline_provider}'; $env:MS_365_VMS_PIPELINE_URL = '${var.ms_365_vms_pipeline_url}'; $env:MS_365_VMS_PIPELINE_TOKEN = '${var.ms_365_vms_pipeline_token}'; $env:MS_365_VMS_PIPELINE_LABELS = '${var.ms_365_vms_pipeline_labels}'; .\\common\\Install-PipelineAgent.ps1;\"",
    ]

    on_failure = "continue"
  }

  depends_on = [
    "null_resource.dependency_getter",
  ]

}

resource "null_resource" "dependency_setter" {
  depends_on = [
    "azurerm_virtual_machine.main"
  ]
}

output "depended_on" {
  value = "${null_resource.dependency_setter.id}"
}
