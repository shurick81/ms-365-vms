$configName = "DomainClient";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $DomainAdminCredential
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName ComputerManagementDsc -ModuleVersion 8.4.0

        Node $AllNodes.NodeName
        {

            Computer JoinDomain
            {
                Name        = $NodeName
                DomainName  = $env:MS_365_VMS_DOMAIN_NAME
                Credential  = $DomainAdminCredential
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

$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_DOMAIN_ADMIN_PASSWORD -AsPlainText -Force;
$DomainAdminCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\$env:VM_ADMIN_USERNAME", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -DomainAdminCredential $DomainAdminCredential;
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
