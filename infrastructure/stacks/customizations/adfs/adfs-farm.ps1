$configName = "ADFSFarm";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $DomainAdminCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $ADFSServiceCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName AdfsDsc -ModuleVersion 1.0.0

        Node $AllNodes.NodeName
        {
            $thumbprint = ( Get-ChildItem Cert:\LocalMachine\my | ? { $_.Subject -eq "CN=$env:PublicHostName" } ).Thumbprint;

            AdfsFarm AdfsFarm
            {
                FederationServiceName           = $env:PublicHostName
                FederationServiceDisplayName    = 'Contoso ADFS Service'
                CertificateThumbprint           = $thumbprint
                ServiceAccountCredential        = $ADFSServiceCredential
                Credential                      = $DomainAdminCredential
            }
        
        }
    }
}
catch
{
    Write-Host "$(Get-Date) Exception in defining DCS:";
    $_.Exception.Message;
    Exit 1;
}
$configurationData = @{ AllNodes = @(
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $true; PsDscAllowDomainUser = $true }
) }
$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD -AsPlainText -Force
$DomainAdminCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\custom3094857", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:ADFS_SERVICE_PASSWORD -AsPlainText -Force
$ADFSServiceCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_adfssrv", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -DomainAdminCredential $DomainAdminCredential `
        -ADFSServiceCredential $ADFSServiceCredential;
}
catch
{
    Write-Host "$(Get-Date) Exception in compiling DCS:";
    $_.Exception.Message;
    Exit 1;
}
Write-Host "$(Get-Date) Starting DSC";
try
{
    Start-DscConfiguration $configName -Verbose -Wait -Force;
}
catch
{
    Write-Host "$(Get-Date) Exception in starting DCS:";
    $_.Exception.Message;
    Exit 1;
}
if ( $env:VMDEVOPSSTARTER_NODSCTEST -ne "TRUE" )
{
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
} else {
    Write-Host "$(Get-Date) Skipping tests";
}
Exit 0;
