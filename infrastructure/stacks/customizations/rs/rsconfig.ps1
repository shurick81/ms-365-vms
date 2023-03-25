$configName = "RSConfig";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $InstallAccountCredential,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SqlRSAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0
        Import-DscResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 9.1.0
        Import-DscResource -ModuleName SqlServerDsc -ModuleVersion 16.1.0
        Import-DscResource -ModuleName NetworkingDsc -ModuleVersion 7.4.0.0

        Node $AllNodes.NodeName
        {

            UserRightsAssignment LogonAsAService
            {
                Policy      = "Log_on_as_a_service"
                Identity    = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs"
            }

            xService RSService
            {
                Name        = "SQLServerReportingServices"
                Credential  = $SqlRSAccountCredential
                DependsOn   = "[UserRightsAssignment]LogonAsAService"
            }

            SqlRS ReportingServicesConfig
            {
                InstanceName            = 'SSRS'
                DatabaseServerName      = $rsDatabaseInstance.Split( "\" )[0]
                DatabaseInstanceName    = $rsDatabaseInstance.Split( "\" )[1]
                PsDscRunAsCredential    = $InstallAccountCredential
                DependsOn               = "[xService]RSService"
            }

            FireWall AllowHTTP
            {
                Name        = "HTTP"
                DisplayName = "HTTP"
                Ensure      = "Present"
                Enabled     = "True"
                Profile     = 'Domain', 'Private', 'Public'
                Direction   = "InBound"
                LocalPort   = 80
                Protocol    = "TCP"
                Description = "Firewall rule to allow web sites publishing"
            }

            FireWall WMI-WINMGMT-In-TCP
            {
                Name        = "WMI-WINMGMT-In-TCP"
                Enabled     = "True"
            }

            FireWall WMI-RPCSS-In-TCP
            {
                Name        = "WMI-RPCSS-In-TCP"
                Enabled     = "True"
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

$securedPassword = ConvertTo-SecureString $env:INSTALL_PASSWORD -AsPlainText -Force
$InstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_install", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:RS_SERVICE_PASSWORD -AsPlainText -Force
$SqlRSAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -InstallAccountCredential $InstallAccountCredential `
        -SqlRSAccountCredential $SqlRSAccountCredential;
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
