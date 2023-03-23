$configName = "DevMedia";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName xPSDesiredStateConfiguration -Name xRemoteFile -ModuleVersion 9.1.0

        Node $AllNodes.NodeName
        {

            if ( $env:VMDEVOPSSTARTER_LOCALVS -eq 1 )
            {

                xRemoteFile VSMediaArchive
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/VS2022.zip"
                    DestinationPath = "C:\Install\VS2022.zip"
                    MatchSource     = $false
                }

                Archive VSMediaArchiveUnpacked
                {
                    Ensure      = "Present"
                    Path        = "C:\Install\VS2022.zip"
                    Destination = "C:\Install\VSInstall"
                    DependsOn   = "[xRemoteFile]VSMediaArchive"
                }

            } else {

                xRemoteFile VSMediaBootstrapperDownloaded
                {
                    Uri             = "https://download.visualstudio.microsoft.com/download/pr/0502e0d3-64a5-4bb8-b049-6bcbea5ed247/bca5210f6129451f8f692df1d314e8bd6336f0f62e26d82fccc6c157c4092861/vs_Professional.exe"
                    DestinationPath = "C:\Install\VSInstall\vs_professional.exe"
                    MatchSource     = $false
                }

            }

            if ( $env:VMDEVOPSSTARTER_LOCALVS -eq 1 )
            {

                xRemoteFile SSMSMedia
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/SSMS-Setup-ENU.exe"
                    DestinationPath = "C:\Install\SSMS-Setup-ENU.exe"
                    MatchSource     = $false
                }

                xRemoteFile PowerBIDesktopRSFilePresent
                {
                    Uri             = "http://$env:PACKER_HTTP_ADDR/PBIDesktopRS_x64.msi"
                    DestinationPath = "C:\Install\PowerBI\PBIDesktopRS_x64.msi"
                    MatchSource     = $false
                }

            } else {

                xRemoteFile SSMSMedia
                {
                    Uri             = "https://download.microsoft.com/download/a/3/2/a32ae99f-b6bf-4a49-a076-e66503ccb925/SSMS-Setup-ENU.exe"
                    DestinationPath = "C:\Install\SSMS-Setup-ENU.exe"
                    MatchSource     = $false
                }

                xRemoteFile PowerBIDesktopRSFilePresent
                {
                    Uri             = "https://download.microsoft.com/download/7/0/A/70AD68EF-5085-4DF2-A3AB-D091244DDDBF/PBIDesktopRS_x64.msi"
                    DestinationPath = "C:\Install\PowerBI\PBIDesktopRS_x64.msi"
                    MatchSource     = $false
                }

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
