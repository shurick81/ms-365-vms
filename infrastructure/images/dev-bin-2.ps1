$configName = "DevBin";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName cChoco -ModuleVersion 2.3.1.0

        Node $AllNodes.NodeName
        {

            cChocoInstaller ChocoInstalled
            {
                InstallDir              = "c:\choco"
                #Customizing the installation script temporary for the workaround of https://github.com/chocolatey/cChoco/issues/151
                #TODO: replace with a permanent solution
                ChocoInstallScriptUrl = "https://gist.githubusercontent.com/artisticcheese/d934c1fb704a3e67b3c68283bcabca66/raw/9345bcb115ee7350172fa00085514212245a1c65/install.ps1"
            }

            cChocoPackageInstaller VSCodeInstalled
            {
                Name                    = "vscode"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller FiddlerInstalled
            {
                Name                    = "fiddler"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
            
            cChocoPackageInstaller GitInstalled
            {
                Name                    = "git"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
            
            cChocoPackageInstaller SoapuiInstalled
            {
                Name                    = "soapui"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller NodejsInstalled
            {
                Name                    = "nodejs-lts"
                Version                 = "10.16.3"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller NotepadplusplusInstalled
            {
                Name                    = "notepadplusplus"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
    
            cChocoPackageInstaller PostmanInstalled
            {
                Name                    = "postman"
                Version                 = "10.21.0"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }

            cChocoPackageInstaller XrmToolBoxInstalled
            {
                Name                    = "xrmtoolbox"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
    
            cChocoPackageInstaller GitExtensionsInstalled
            {
                Name                    = "gitextensions"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
            }
    
            #cChocoPackageInstaller NCrunchForVS2019Installed
            #{
            #    Name                    = "ncrunch-vs2019"
            #    DependsOn               = "[cChocoInstaller]ChocoInstalled"
            #}
    
            cChocoPackageInstaller NCrunchForVS2022Installed
            {
                Name                    = "ncrunch-vs2022"
                DependsOn               = "[cChocoInstaller]ChocoInstalled"
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
