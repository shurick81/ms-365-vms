$configName = "SQLBin";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.4.0.0
        Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.3.1

        Node $AllNodes.NodeName
        {

            FireWall SQLFirewallRuleTCP
            {
                Name        = "AllowSQLConnection"
                DisplayName = "Allow SQL Connection"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = ("Domain")
                Direction   = "InBound"
                LocalPort   = ("1433")
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall SQLFirewallRuleBrowser
            {
                Name        = "AllowSQLBrowser"
                DisplayName = "Allow SQL Browser"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = ("Domain")
                Direction   = "InBound"
                LocalPort   = ("1434")
                Protocol    = "UDP"
                Description = "Firewall rule to allow SQL Browser"
            }

            SQLSetup SQLSetup
            {
                InstanceName            = "SQLInstance01"
                SourcePath              = "F:\"
                Features                = "SQLENGINE,FULLTEXT"
                InstallSharedDir        = "C:\Program Files\Microsoft SQL Server\SQLInstance01"
                SQLSysAdminAccounts     = @('Administrators')
                UpdateEnabled           = "True"
                UpdateSource            = "C:\Install\SQLUpdates"
                SQMReporting            = "False"
                ErrorReporting          = "True"
                AgtSvcStartupType       = "Automatic"
                BrowserSvcStartupType   = "Automatic"
            }

            SqlMemory SQLServerMaxMemoryIs2GB
            {
                ServerName      = $NodeName
                DynamicAlloc    = $false
                MinMemory       = 1024
                MaxMemory       = 2048
                InstanceName    = "SQLInstance01"
                DependsOn       = "[SQLSetup]SQLSetup"
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
