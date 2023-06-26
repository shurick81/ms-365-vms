$configName = "DevBin";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration

        Node $AllNodes.NodeName
        {

            if ( $env:VMDEVOPSSTARTER_LOCALVS -eq 1 )
            {

                Script VSInstallerRunning
                {
                    SetScript = {
                        Start-Process -FilePath C:\Install\VSInstall\vs_professional.exe -ArgumentList '--quiet --wait --add Microsoft.VisualStudio.Workload.Office --includeRecommended --add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.ManagedDesktop --remove Microsoft.ComponentGroup.Blend --add Microsoft.VisualStudio.Component.JavaScript.TypeScript --add Microsoft.VisualStudio.Workload.NetWeb --norestart' -Wait;
                    }
                    TestScript = {
                        $products = Get-WmiObject -Class Win32_Product | ? { $_.Name -eq "Microsoft Visual Studio Setup Configuration" }
                        if ( $products ) {
                            Write-Host "Products found";
                            return $true;
                        } else {
                            Write-Host "Products not found";
                            return $false;
                        }
                    }
                    GetScript = {
                        $installedApplications = Get-WmiObject -Class Win32_Product | ? { $_.name -eq "Microsoft Visual Studio Setup Configuration" }
                        return $installedApplications
                    }
                }

            } else {

                Script VSInstallerRunning
                {
                    SetScript = {
                        Start-Process -FilePath C:\Install\VSInstall\vs_professional.exe -ArgumentList '--quiet --wait --add Microsoft.VisualStudio.Workload.Office --includeRecommended --add Microsoft.VisualStudio.Workload.CoreEditor --add Microsoft.VisualStudio.Workload.ManagedDesktop --remove Microsoft.ComponentGroup.Blend --add Microsoft.VisualStudio.Component.JavaScript.TypeScript --add Microsoft.VisualStudio.Workload.NetWeb --norestart' -Wait;
                    }
                    TestScript = {
                        $products = Get-WmiObject -Class Win32_Product | ? { $_.Name -eq "Microsoft Visual Studio Setup Configuration" }
                        if ( $products ) {
                            Write-Host "Products found";
                            return $true;
                        } else {
                            Write-Host "Products not found";
                            return $false;
                        }
                    }
                    GetScript = {
                        $installedApplications = Get-WmiObject -Class Win32_Product | ? { $_.name -eq "Microsoft Visual Studio Setup Configuration" }
                        return $installedApplications
                    }
                }

            }

            Package SSMS
            {
                Ensure      = "Present"
                Name        = "SQL Server Management Studio"
                Path        = "C:\Install\SSMS-Setup-ENU.exe"
                Arguments   = "/install /passive /norestart"
                ProductId   = "6423D26F-D197-40D4-B05C-958283128732"
            }

            Package PowerBIDesktopRS
            {
                Ensure      = 'Present'
                Name        = 'Microsoft Power BI Desktop (January 2023) (x64)'
                Path        = 'C:\Install\PowerBI\PBIDesktopRS_x64.msi'
                Arguments   = '/qn /norestart ACCEPT_EULA=1'
                ProductId   = '66BB5E82-D16D-4C9D-B8A2-6A73483F32DF'
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
#Get-WmiObject Win32_Product
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
