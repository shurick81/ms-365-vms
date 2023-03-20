$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD -AsPlainText -Force;
$DomainAdminCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\$env:VM_ADMIN_USERNAME", $securedPassword );
Invoke-Command $env:COMPUTERNAME -Credential $DomainAdminCredential {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]
        $MembersToInclude
    )
    $MembersToInclude.Split( "," ) | % {
        Add-LocalGroupMember -Group "Administrators" -Member $_ -Verbose;
    }
} -ArgumentList $MembersToInclude
