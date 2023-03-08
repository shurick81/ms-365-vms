variable "environmentId" {}
variable "location" {}
variable "vm_admin_username" {}
variable "vm_admin_password" {}
variable "vm_resource_group_name" {}
variable "main_subnet_id" {}
variable "image_id" {}
variable "vm_name" {}
variable "vm_size" {}
variable "ms_365_vms_domain_name" {}
variable "vm_domain_name_label" {}
variable "rs_service_password" {}
variable "crm_test_1_password" {}
variable "crm_test_2_password" {}
variable "crm_install_password" {}
variable "crm_service_password" {}
variable "crm_deployment_service_password" {}
variable "crm_sandbox_service_password" {}
variable "crm_vss_writer_password" {}
variable "crm_async_service_password" {}
variable "crm_monitoring_service_password" {}
variable "ms_365_vms_ssl_cache_unc" {}
variable "ms_365_vms_ssl_cache_username" {}
variable "ms_365_vms_ssl_cache_password" {}
variable "ms_365_vms_ssl_pfx_password" {}
variable "ms_365_vms_dynamics_crm_base" {}
variable "ms_365_vms_dynamics_crm_update" {}
variable "ms_365_vms_dynamics_crm_re_update" {}
variable "ms_365_vms_dynamics_crm_base_iso_currency_code" {}
variable "ms_365_vms_dynamics_crm_base_currency_name" {}
variable "ms_365_vms_dynamics_crm_base_currency_symbol" {}
variable "ms_365_vms_dynamics_crm_base_currency_precision" {}
variable "ms_365_vms_dynamics_crm_organization_collation" {}
variable "dependencies" {
  type = "list"
}

# Empty machine for installing any Windows servers

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
  domain_name_label   = "${lower(var.vm_domain_name_label)}"

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

  security_rule {
    name                       = "HTTP"
    priority                   = 315
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 320
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
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
  primary_network_interface_id  = "${azurerm_network_interface.nic01.id}"
  vm_size                       = "${var.vm_size}"
  delete_os_disk_on_termination = true
  #license_type                  = "Windows_Server"

  storage_os_disk {
    name              = "${var.vm_name}-disk-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
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

    source      = "./../../domain.ps1"
    destination = ".\\common\\domain.ps1"
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
      "powershell.exe -command \"$env:VMDEVOPSSTARTER_NODSCTEST = 'TRUE'; $env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:VM_ADMIN_USERNAME = '${var.vm_admin_username}'; $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD = '${var.vm_admin_password}'; .\\common\\domain.ps1; shutdown /r /f /t 5 /c 'forced reboot'; net stop WinRM\"",
    ]

    on_failure = "continue"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:VM_ADMIN_USERNAME = '${var.vm_admin_username}'; $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD = '${var.vm_admin_password}'; .\\common\\domain.ps1\"",
    ]
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

    source      = "./../../customizations/crm/crmdomaincustomizations.ps1"
    destination = ".\\common\\crmdomaincustomizations.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:RS_SERVICE_PASSWORD = '${var.rs_service_password}'; $env:CRM_TEST_1_PASSWORD = '${var.crm_test_1_password}'; $env:CRM_TEST_2_PASSWORD = '${var.crm_test_2_password}'; $env:CRM_INSTALL_PASSWORD = '${var.crm_install_password}'; $env:CRM_SERVICE_PASSWORD = '${var.crm_service_password}'; $env:CRM_DEPLOYMENT_SERVICE_PASSWORD = '${var.crm_deployment_service_password}'; $env:CRM_SANDBOX_SERVICE_PASSWORD = '${var.crm_sandbox_service_password}'; $env:CRM_VSS_WRITER_PASSWORD = '${var.crm_vss_writer_password}'; $env:CRM_ASYNC_SERVICE_PASSWORD = '${var.crm_async_service_password}'; $env:CRM_MONITORING_SERVICE_PASSWORD = '${var.crm_monitoring_service_password}'; .\\common\\crmdomaincustomizations.ps1\"",
    ]
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

    source      = "./../../customizations/crm/crmdomainlocalinstall.ps1"
    destination = ".\\common\\crmdomainlocalinstall.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; .\\common\\crmdomainlocalinstall.ps1\"",
    ]
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

    source      = "./../../dbservernamefix.ps1"
    destination = ".\\common\\dbservernamefix.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; .\\common\\dbservernamefix.ps1\"",
    ]
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

    source      = "./../../sqlconfig.ps1"
    destination = ".\\common\\sqlconfig.ps1"
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
      "powershell.exe -command \".\\common\\sqlconfig.ps1\"",
    ]
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline     = [
      "powershell.exe -command \"Stop-Service ReportServer`$RSInstance01; Stop-Service W3SVC\""
    ]
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
      #host = azurerm_public_ip.main.ip_address
    }
    source      = "./../../Update-SSLCertificate.ps1"
    destination = ".\\common\\Update-SSLCertificate.ps1"
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline     = [
      "powershell.exe -command \"$env:PublicHostName = '${var.vm_domain_name_label}.${var.location}.cloudapp.azure.com'; $env:MS_365_VMS_SSL_CACHE_UNC = '${var.ms_365_vms_ssl_cache_unc}'; $env:MS_365_VMS_SSL_CACHE_USERNAME = '${var.ms_365_vms_ssl_cache_username}'; $env:MS_365_VMS_SSL_CACHE_PASSWORD = '${var.ms_365_vms_ssl_cache_password}'; $env:MS_365_VMS_SSL_PFX_PASSWORD = '${var.ms_365_vms_ssl_pfx_password}'; .\\common\\Update-SSLCertificate.ps1;\""
    ]
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline     = [
      "powershell.exe -command \"Start-Service ReportServer`$RSInstance01; Start-Service W3SVC\""
    ]
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

    source      = "./../../rs-serviceaccount-update.ps1"
    destination = ".\\common\\rs-serviceaccount-update.ps1"
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
      "powershell.exe -command \"$env:SERVICE_NAME = 'ReportServer$RSInstance01'; $env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:RS_SERVICE_PASSWORD = '${var.rs_service_password}'; $env:VM_ADMIN_USERNAME = '${var.vm_admin_username}'; $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD = '${var.vm_admin_password}'; .\\common\\rs-serviceaccount-update.ps1\"",
    ]
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
      "powershell.exe -command \"Install-Module -Name SqlServerDsc -Force -RequiredVersion 15.2.0\"",
    ]
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

    source      = "./../../rsconfig-legacy.ps1"
    destination = ".\\common\\rsconfig-legacy.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:RS_SERVICE_PASSWORD = '${var.rs_service_password}'; $env:VM_ADMIN_USERNAME = '${var.vm_admin_username}'; $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD = '${var.vm_admin_password}'; .\\common\\rsconfig-legacy.ps1\"",
    ]
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

    source      = "./../../xcredclient-ad.ps1"
    destination = ".\\common\\xcredclient-ad.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; .\\common\\xcredclient-ad.ps1\"",
    ]
  }

  provisioner "local-exec" {
    command = "sleep 60"
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
      "powershell.exe -command \"shutdown /r /f /t 5 /c 'forced reboot'; net stop WinRM\"",
    ]
    on_failure = "continue"
  }

  provisioner "local-exec" {
    command = "sleep 60"
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

    source      = "./../../xcredclient.ps1"
    destination = ".\\common\\xcredclient.ps1"
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
      "powershell.exe -command \"$env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; .\\common\\xcredclient.ps1;\"",
    ]
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

    source      = "./../../customizations/crm/Install-Dynamics.ps1"
    destination = ".\\common\\Install-Dynamics.ps1"
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline     = [
      "powershell.exe -command \"$env:MS_365_VMS_DYNAMICS_CRM_BASE = '${var.ms_365_vms_dynamics_crm_base}';$env:MS_365_VMS_DYNAMICS_CRM_UPDATE = '${var.ms_365_vms_dynamics_crm_update}';$env:MS_365_VMS_DYNAMICS_CRM_RE_UPDATE = '${var.ms_365_vms_dynamics_crm_re_update}'; $env:SQL_SERVER = $env:COMPUTERNAME + '\\SqlInstance01'; $env:MS_365_VMS_DOMAIN_NAME = '${var.ms_365_vms_domain_name}'; $env:CRM_INSTALL_PASSWORD = '${var.crm_install_password}'; $env:CRM_SERVICE_PASSWORD = '${var.crm_service_password}'; $env:CRM_DEPLOYMENT_SERVICE_PASSWORD = '${var.crm_deployment_service_password}'; $env:CRM_SANDBOX_SERVICE_PASSWORD = '${var.crm_sandbox_service_password}'; $env:CRM_VSS_WRITER_PASSWORD = '${var.crm_vss_writer_password}'; $env:CRM_ASYNC_SERVICE_PASSWORD = '${var.crm_async_service_password}'; $env:CRM_MONITORING_SERVICE_PASSWORD = '${var.crm_monitoring_service_password}'; $env:MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE = '${var.ms_365_vms_dynamics_crm_base_iso_currency_code}'; $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME = '${var.ms_365_vms_dynamics_crm_base_currency_name}'; $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL = '${var.ms_365_vms_dynamics_crm_base_currency_symbol}'; $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION = '${var.ms_365_vms_dynamics_crm_base_currency_precision}'; $env:MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION = '${var.ms_365_vms_dynamics_crm_organization_collation}'; $env:REPORT_SERVER_HOST_NAME = $env:COMPUTERNAME; $env:CRM_HOST_NAME = '${var.vm_domain_name_label}.${var.location}.cloudapp.azure.com'; .\\common\\Install-Dynamics.ps1\""
    ]
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

    source      = "./../../local-site.ps1"
    destination = ".\\common\\local-site.ps1"
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline     = [
      "powershell.exe -command \"$env:USERNAME = '${var.ms_365_vms_domain_name}\\_crmadmin'; $env:PASSWORD = '${var.crm_install_password}'; $env:HOST_NAME = '${var.vm_domain_name_label}.${var.location}.cloudapp.azure.com'; .\\common\\local-site.ps1\""
    ]
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline = [
      "powershell.exe -command \"Write-Host `\"Remove-Item C:\\Users\\_crmadmin\\AppData\\Roaming\\NuGet\\nuget.config\""
    ]
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
      #host = azurerm_public_ip.main.ip_address
    }
    inline = [
      "powershell.exe -command \"Write-Host `\"$(Get-Date) Provisioning is done`\"\""
    ]
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
