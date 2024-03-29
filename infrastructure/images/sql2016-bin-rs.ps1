$configName = "SQLBin";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.3.1

        Node $AllNodes.NodeName
        {

            SQLSetup SQLSetup
            {
                InstanceName            = "SSRS"
                SourcePath              = "F:\"
                Features                = "RS"
                ProductKey              = "22222-00000-00000-00000-00000"
                InstallSharedDir        = "C:\Program Files\Microsoft SQL Server\SSRS"
                SQLSysAdminAccounts     = "BUILTIN\Administrators"
                UpdateEnabled           = "True"
                UpdateSource            = "C:\Install\SQLUpdates"
                SQMReporting            = "False"
                ErrorReporting          = "True"
                BrowserSvcStartupType   = "Automatic"
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
#Write-Host "Get-Content 'C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Log\Summary.txt';"
#Get-Content 'C:\Program Files\Microsoft SQL Server\130\Setup Bootstrap\Log\Summary.txt';
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
