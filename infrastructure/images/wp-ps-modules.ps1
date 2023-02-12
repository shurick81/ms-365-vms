$configName = "WorkPlaceModule";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName PackageManagementProviderResource -ModuleVersion 1.0.3

        Node $AllNodes.NodeName
        {

            PSModule "PSModule_MSOnline"
            {
                Ensure              = "Present"
                Name                = "MSOnline"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "1.1.183.57"
            }

            PSModule "PSModule_AzureAD"
            {
                Ensure              = "Present"
                Name                = "AzureAD"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.0.2.130"
            }

            PSModule "PSModule_cChoco"
            {
                Ensure              = "Present"
                Name                = "cChoco"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.3.1.0"
            }

            PSModule "PSModule_xCredssp"
            {
                Ensure              = "Present"
                Name                = "xCredssp"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "1.3.0.0"
            }

            PSModule "PSModule_PSPKI"
            {
                Ensure              = "Present"
                Name                = "PSPKI"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "3.3.0.0"
            }

            PSModule "PSModule_PnP"
            {
                Ensure              = "Present"
                Name                = "SharePointPnPPowerShell2013"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "3.17.2001.2"
            }

            PSModule "PSModule_SecurityPolicyDsc"
            {
                Ensure              = "Present"
                Name                = "SecurityPolicyDsc"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.10.0.0"
            }

            PSModule "PSModule_xWebAdministration"
            {
                Ensure              = "Present"
                Name                = "xWebAdministration"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "3.1.1"
            }

            PSModule "PSModule_Microsoft.Xrm.Data.Powershell"
            {
                Ensure              = "Present"
                Name                = "Microsoft.Xrm.Data.Powershell"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.8.1.3"
            }

            WindowsFeature RSAT-AD-PowerShell
            {
                Name                    = "RSAT-AD-PowerShell"
                Ensure                  = 'Present'
                IncludeAllSubFeature    = $true
            }

            PSModule "PSModule_ReportingServicesTools"
            {
                Ensure              = "Present"
                Name                = "ReportingServicesTools"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "0.0.5.7"
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
