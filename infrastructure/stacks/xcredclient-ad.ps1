$configName = "XCredClient";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xCredssp -ModuleVersion 1.3.0.0

        Node $AllNodes.NodeName
        {

            xCredssp CredsspClient
            {
                Ensure = "Present"
                Role = "Client"
                DelegateComputers = "*.$env:MS_365_VMS_DOMAIN_NAME"
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
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
) }
Write-Host "$(Get-Date) Compiling DSC";
try
{
    &$configName `
        -ConfigurationData $configurationData;
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
    Start-DscConfiguration $configName -Verbose -Force;
}
catch
{
    Write-Host "$(Get-Date) Exception in starting DCS:";
    $_.Exception.Message;
    Exit 1;
}
Exit 0;
