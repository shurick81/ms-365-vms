$configName = "SQLConfig";
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

            SqlMaxDop SQLMaxDop
            {
                Ensure          = 'Present'
                DynamicAlloc    = $false
                MaxDop          = 1
                InstanceName    = "SQLInstance01"
            }

            SqlProtocol SqlProtocol
            {
                InstanceName    = 'SQLInstance01'
                ProtocolName    = 'TcpIp'
                Enabled         = $true
            }

            FireWall AllowSQL2014Service
            {
                Name        = "AllowSQL2014Service"
                DisplayName = "Allow SQL 2014 Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                Program     = 'C:\Program Files\Microsoft SQL Server\MSSQL12.SQLInstance01\MSSQL\Binn\sqlservr.exe'
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall AllowSQL2016Service
            {
                Name        = "AllowSQL2016Service"
                DisplayName = "Allow SQL 2016 Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                Program     = 'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLInstance01\MSSQL\Binn\sqlservr.exe'
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall AllowSQL2017Service
            {
                Name        = "AllowSQL2017Service"
                DisplayName = "Allow SQL 2017 Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                Program     = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLInstance01\MSSQL\Binn\sqlservr.exe'
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall AllowSQL2019Service
            {
                Name        = "AllowSQL2019Service"
                DisplayName = "Allow SQL 2019 Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                Program     = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLInstance01\MSSQL\Binn\sqlservr.exe'
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall AllowSQL2022Service
            {
                Name        = "AllowSQL2022Service"
                DisplayName = "Allow SQL 2022 Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                Program     = 'C:\Program Files\Microsoft SQL Server\MSSQL16.SQLInstance01\MSSQL\Binn\sqlservr.exe'
                Protocol    = "TCP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall AllowSQLBrowser
            {
                Name        = "AllowSQLBrowser"
                DisplayName = "Allow SQL Browser"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                LocalPort   = 1434
                Protocol    = "UDP"
                Description = "Firewall rule to allow SQL communication"
            }

            FireWall DirectoryService
            {
                Name        = "DirectoryService"
                DisplayName = "Directory Service"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                LocalPort   = 445
                Protocol    = "TCP"
                Description = "Firewall rule to allow AD communication"
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
