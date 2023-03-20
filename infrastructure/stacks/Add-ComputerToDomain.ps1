$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD -AsPlainText -Force;
$DomainAdminCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\$env:VM_ADMIN_USERNAME", $securedPassword );
Add-Computer -DomainName $env:MS_365_VMS_DOMAIN_NAME -Credential $DomainAdminCredential -Force -PassThru -Verbose;
