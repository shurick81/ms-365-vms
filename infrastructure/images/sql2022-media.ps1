$configName = "SQLMedia";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )
    
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion 8.4.0.0
        Import-DscResource -ModuleName StorageDsc -ModuleVersion 4.9.0.0
    
        Node $AllNodes.NodeName
        {
            $provider = $null
            $computerSystem = Get-WmiObject -Class Win32_ComputerSystem;
            $computerSystem;
            if ( $computerSystem.Model -eq "VirtualBox" ) {
                Write-Host "Model is VirtualBox";
                $provider = "virtualbox";
            }
            if ( ( $computerSystem.Manufacturer -eq "Microsoft" ) -or ( $computerSystem.Manufacturer -eq "Microsoft Corporation" ) ) {
                Write-Host "Manufacturer is Microsoft";
                $provider = "hyperv";
                Get-DnsClient | % { if ( ( $_.ConnectionSpecificSuffix -like "*.cloudapp.net" ) -or ( $_.ConnectionSpecificSuffix -like "*.microsoft.com" ) ) {
                    Write-Host "Found azure interface";
                    $provider = "azure";
                } }
            }
            if ( $provider -eq "azure" )
            {

                xRemoteFile SQLServerImageFilePresent
                {
                    #Uri            = "https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-x64-ENU.iso";
                    Uri            = "https://download.microsoft.com/download/3/8/d/38de7036-2433-4207-8eae-06e247e17b25/SQLServer2022-x64-ENU-Dev.iso";
                    DestinationPath = "C:\Install\SQLRTMImage\SQLServer2022-x64-ENU-Dev.iso"
                    MatchSource     = $false
                }

                #xRemoteFile SQLServerCUFilePresent
                #{
                #    Uri             = "https://download.microsoft.com/download/6/e/7/6e72dddf-dfa4-4889-bc3d-e5d3a0fd11ce/SQLServer2019-KB5011644-x64.exe"
                #    DestinationPath = "C:\Install\SQLUpdates\SQLServer2019-KB5011644-x64.exe"
                #    MatchSource     = $false
                #}

                xRemoteFile SQLServerRSFilePresent
                {
                    Uri             = "https://download.microsoft.com/download/8/3/2/832616ff-af64-42b5-a0b1-5eb07f71dec9/SQLServerReportingServices.exe"
                    DestinationPath = "C:\Install\SQLRTMImage\SQLServerReportingServices.exe"
                    MatchSource     = $false
                }

                xRemoteFile PowerBIReportServerFilePresent
                {
                    Uri             = "https://download.microsoft.com/download/7/0/A/70AD68EF-5085-4DF2-A3AB-D091244DDDBF/PowerBIReportServer.exe"
                    DestinationPath = "C:\Install\PowerBI\PowerBIReportServer.exe"
                    MatchSource     = $false
                }

            } else {

                xRemoteFile SQLServerImageFilePresent
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/SQLServer2022-x64-ENU-Dev.iso"
                    DestinationPath = "C:\Install\SQLRTMImage\SQLServer2022-x64-ENU-Dev.iso"
                    MatchSource     = $false
                }

                #xRemoteFile SQLServerCUFilePresent
                #{
                #    Uri             = "http://$env:PACKER_HTTP_ADDR/SQLServer2019-KB5011644-x64.exe"
                #    DestinationPath = "C:\Install\SQLUpdates\SQLServer2019-KB5011644-x64.exe"
                #    MatchSource     = $false
                #}

                xRemoteFile SQLServerRSFilePresent
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/SQLServerReportingServices.exe"
                    DestinationPath = "C:\Install\SQLRTMImage\SQLServerReportingServices.exe"
                    MatchSource     = $false
                }

                xRemoteFile PowerBIReportServerFilePresent
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/PowerBIReportServer.exe"
                    DestinationPath = "C:\Install\PowerBI\PowerBIReportServer.exe"
                    MatchSource     = $false
                }

            }
    
            MountImage SQLServerImageMounted
            {
                ImagePath   = "C:\Install\SQLRTMImage\SQLServer2022-x64-ENU-Dev.iso"
                DriveLetter = 'F'
                DependsOn   = "[xRemoteFile]SQLServerImageFilePresent"
            }
    
            WaitForVolume SQLServerImageMounted
            {
                DriveLetter         = 'F'
                RetryIntervalSec    = 5
                RetryCount          = 10
                DependsOn           = "[MountImage]SQLServerImageMounted"
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
    if ( $env:VMDEVOPSSTARTER_NODSCTEST )
    {
        Start-DscConfiguration $configName -Verbose -Force;
        Sleep 20;
        0..720 | % {
            $res = Get-DscLocalConfigurationManager;
            Write-Host $res.LCMState;
            if ( ( $res.LCMState -ne "Idle" ) -and ( $res.LCMState -ne "PendingConfiguration" ) ) {
                Sleep 10;
            }
        }
        if ( ( $res.LCMState -ne "Idle" ) -and ( $res.LCMState -ne "PendingConfiguration" ) ) {
            Write-Host "Timouted waiting for LCMState"
            Exit 1;
        }
    } else {
        Start-DscConfiguration $configName -Verbose -Wait -Force;
    }
}
catch
{
    Write-Host "$(Get-Date) Exception in starting DCS:";
    $_.Exception.Message;
    Exit 1;
}
if ( $env:SPDEVOPSSTARTER_NODSCTEST -ne "TRUE" )
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
