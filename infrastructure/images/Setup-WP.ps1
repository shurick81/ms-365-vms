$configName = "WPSetup";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName ComputerManagementDsc -ModuleVersion 8.4.0
        Import-DSCResource -ModuleName cChoco -ModuleVersion 2.3.1.0

        Node $AllNodes.NodeName
        {

            WindowsFeatureSet WorkPlaceFeatures
            {
                Name                    = @( "Telnet-Client", "RSAT-DNS-Server", "RSAT-ADDS", "RSAT-ADCS" )
                Ensure                  = 'Present'
                IncludeAllSubFeature    = $true
            }

            cChocoInstaller ChocoInstalled
            {
                InstallDir  = "c:\choco"
                #Customizing the installation script temporary for the workaround of https://github.com/chocolatey/cChoco/issues/151
                #TODO: replace with a permanent solution
                ChocoInstallScriptUrl = "https://gist.githubusercontent.com/artisticcheese/d934c1fb704a3e67b3c68283bcabca66/raw/9345bcb115ee7350172fa00085514212245a1c65/install.ps1"
            }

            cChocoPackageInstaller ADExplorer
            {
                Name        = "adexplorer"
                DependsOn   = "[cChocoInstaller]ChocoInstalled"
            }

            #cChocoPackageInstaller googlechrome
            #{
            #    Name        = "googlechrome"
            #    DependsOn   = "[cChocoInstaller]ChocoInstalled"
            #}

            cChocoPackageInstaller firefox
            {
                Name        = "firefox"
                DependsOn   = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller NotepadplusplusInstalled
            {
                Name                    = "notepadplusplus"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            #cChocoPackageInstaller Office365businessInstalled
            #{
            #    Name                    = "office365business"
            #    DependsOn               = "[cChocoInstaller]ChocoInstalled"
            #}

            IEEnhancedSecurityConfiguration 'DisableForAdministrators'
            {
                Role    = 'Administrators'
                Enabled = $false
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
