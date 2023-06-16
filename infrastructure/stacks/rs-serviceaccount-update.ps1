# grant Log On As A Service
$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD -AsPlainText -Force;
$DomainAdminCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\$env:VM_ADMIN_USERNAME", $securedPassword );
Invoke-Command $env:COMPUTERNAME -Credential $DomainAdminCredential {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]
        $MS_365_VMS_DOMAIN_NAME,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]
        $VM_ADMIN_USERNAME,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [String]
        $MS_365_VMS_DOMAIN_ADMIN_PASSWORD
    )
    $accountName = "$($MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs";
    $ldapDomain = "LDAP://DC=$($MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )";
    Write-Host "LDAP domain: $ldapDomain";
    $dom = New-Object System.DirectoryServices.DirectoryEntry( $ldapDomain, $VM_ADMIN_USERNAME, $MS_365_VMS_DOMAIN_ADMIN_PASSWORD );
    if ( $dom.Path -ne $null )
    {
        $ds = New-Object DirectoryServices.DirectorySearcher( $dom );
        $shortUserName = $accountName.Split( "\" )[1];
        $ds.filter = "sAMAccountName=$shortUserName";
        $result = $ds.FindOne();
        if ( $result -ne $null )
        {
            $binarySID = $result[0].Properties["objectSid"][0];
            $stringSID = (New-Object System.Security.Principal.SecurityIdentifier($binarySID,0)).Value;
            Write-Host "AD User Sid: $stringSID";
        } else {
            Write-Host "Found 0 objects";
        }
    } else {
        Write-Host "DS is not connected";
    }

    $AccountSid = $stringSID;

    $ExportFile = "$env:TEMP\CurrentConfig.inf"
    $SecDb = "$env:TEMP\secedt.sdb"
    $ImportFile = "$env:TEMP\NewConfig.inf"

    #Export the current configuration
    secedit /export /cfg $ExportFile

    #Find the current list of SIDs having already this right
    $CurrentServiceLogonRight = Get-Content -Path $ExportFile |
        Where-Object -FilterScript {$PSItem -match 'SeServiceLogonRight'}

    #Create a new configuration file and add the new SID
$FileContent = @'
[Unicode]
Unicode=yes
[System Access]
[Event Audit]
[Registry Values]
[Version]
signature="$CHICAGO$"
Revision=1
[Profile Description]
Description=GrantLogOnAsAService security template
[Privilege Rights]
{0}*{1}
'@ -f $(
            if($CurrentServiceLogonRight){"$CurrentServiceLogonRight,"}
            else{'SeServiceLogonRight = '}
        ), $AccountSid

    Set-Content -Path $ImportFile -Value $FileContent

    #Import the new configuration 
    secedit /import /db $SecDb /cfg $ImportFile
    secedit /configure /db $SecDb
} -ArgumentList $env:MS_365_VMS_DOMAIN_NAME, $env:VM_ADMIN_USERNAME, $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD

# change the service account
$changeServiceArguments = @{
    StartName       = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs"
    StartPassword   = $env:RS_SERVICE_PASSWORD
}
Write-Host "Finding $env:SERVICE_NAME service"
$serviceCimInstance = Get-CimInstance -ClassName 'Win32_Service' -Filter "Name='$env:SERVICE_NAME'";
Invoke-CimMethod -InputObject $ServiceCimInstance -MethodName 'Change' -Arguments $changeServiceArguments;
Stop-Service $env:SERVICE_NAME -ErrorAction Stop
Start-Service $env:SERVICE_NAME -ErrorAction Stop
