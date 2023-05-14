$configName = "SQLMediaClean";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.9.0.0

        Node $AllNodes.NodeName
        {

            MountImage SQLServerImageNotMounted
            {
                ImagePath   = "C:\Install\SQLRTMImage\SQLServer2022-x64-ENU-Dev.iso"
                Ensure      = 'Absent'
            }

            File SQLServerImageAbsent {
                Ensure          = "Absent"
                DestinationPath = "C:\Install\SQLRTMImage\SQLServer2022-x64-ENU-Dev.iso"
                Force           = $true
                DependsOn       = "[MountImage]SQLServerImageNotMounted"
            }

            File SQLServerRSImageAbsent {
                Ensure          = "Absent"
                DestinationPath = "C:\Install\SQLRTMImage\SQLServerReportingServices.exe"
                Force           = $true
            }

            File SQLServerUpdatesAbsent {
                DestinationPath = "C:\Install\SQLUpdates"
                Recurse         = $true
                Type            = "Directory"
                Ensure          = "Absent"
                Force           = $true
            }

            File PowerBIReportServerFileAbsent {
                Ensure          = "Absent"
                DestinationPath = "C:\Install\PowerBI\PowerBIReportServer.exe"
                Force           = $true
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
