$configName = "CRMPSModules";
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

            PSModule "PSModule_PSPKI"
            {
                Ensure              = "Present"
                Name                = "PSPKI"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "3.3.0.0"
            }

            PSModule "PSModule_CertificateDsc"
            {
                Ensure              = "Present"
                Name                = "CertificateDsc"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "4.7.0.0"
            }

            PSModule "PSModule_xWebAdministration"
            {
                Ensure              = "Present"
                Name                = "xWebAdministration"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "3.1.1"
            }

            PSModule "PSModule_xSystemSecurity"
            {
                Ensure              = "Present"
                Name                = "xSystemSecurity"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "1.4.0.0"
            }

            PSModule "PSModule_Dynamics365Configuration"
            {
                Ensure              = "Present"
                Name                = "Dynamics365Configuration"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.25.0"
            }

            PSModule "PSModule_SecurityPolicyDsc"
            {
                Ensure              = "Present"
                Name                = "SecurityPolicyDsc"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "2.10.0.0"
            }

            PSModule "PSModule_ReportingServicesTools"
            {
                Ensure              = "Present"
                Name                = "ReportingServicesTools"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "0.0.5.7"
            }

            PSModule "PSModule_NetworkingDsc"
            {
                Ensure              = "Present"
                Name                = "NetworkingDsc"
                Repository          = "PSGallery"
                InstallationPolicy  = "Trusted"
                RequiredVersion     = "7.4.0.0"
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
