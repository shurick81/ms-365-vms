# Following https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/deploy/microsoft-dynamics-365-server-roles#group-membership-requirements ?
$configName = "CRMDomainCustomizations";
Write-Host "$(Get-Date) Defining DSC";
try {
    Configuration $configName
    {
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $InstallAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SqlRSAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.0.1

        Node $AllNodes.NodeName
        {

            ADUser DomainAdminAccountUser
            {
                DomainName              = $env:MS_365_VMS_DOMAIN_NAME
                UserName                = "custom3094857"
                PasswordNeverExpires    = $true
            }

            ADUser InstallAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $InstallAccountCredential.GetNetworkCredential().UserName
                Password             = $InstallAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser SqlRSAccountCredentialUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $SqlRSAccountCredential.GetNetworkCredential().UserName
                Password             = $SqlRSAccountCredential
                PasswordNeverExpires = $true
            }

        }
    }
}
catch {
    Write-Host "$(Get-Date) Exception in defining DCS:";
    $_.Exception.Message;
    Exit 1;
}
$configurationData = @{ AllNodes = @(
        @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
    ) 
}

$securedPassword = ConvertTo-SecureString $env:INSTALL_PASSWORD -AsPlainText -Force
$InstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_install", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:RS_SERVICE_PASSWORD -AsPlainText -Force
$SqlRSAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try {
    &$configName `
        -ConfigurationData $configurationData `
        -InstallAccountCredential $InstallAccountCredential `
        -SqlRSAccountCredential $SqlRSAccountCredential;
}
catch {
    Write-Host "$(Get-Date) Exception in compiling DCS:";
    $_.Exception.Message;
    Exit 1;
}
Write-Host "$(Get-Date) Starting DSC";
try {
    Start-DscConfiguration $configName -Verbose -Wait -Force;
}
catch {
    Write-Host "$(Get-Date) Exception in starting DCS:";
    $_.Exception.Message;
    Exit 1;
}
if ( $env:VMDEVOPSSTARTER_NODSCTEST -ne "TRUE" ) {
    Write-Host "$(Get-Date) Testing DSC";
    try {
        $result = Test-DscConfiguration $configName -Verbose;
        $inDesiredState = $result.InDesiredState;
        $failed = $false;
        $inDesiredState | % {
            if ( !$_ ) {
                Write-Host "$(Get-Date) Test failed";
                Exit 1;
            }
        }
    }
    catch {
        Write-Host "$(Get-Date) Exception in testing DCS:";
        $_.Exception.Message;
        Exit 1;
    }
}
else {
    Write-Host "$(Get-Date) Skipping tests";
}
Exit 0;
