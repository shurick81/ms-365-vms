$configName = "ClientConfiguration";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $Credential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration

        $domainName = "contos00.local";

        Node $AllNodes.NodeName
        {

            Registry CRMHost
            {
                Ensure                  = "Present"
                Key                     = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ZoneMap\Domains\$env:HOST_NAME"
                ValueName               = "https"
                ValueType               = "DWORD"
                ValueData               = "1"
                PsDscRunAsCredential    = $Credential
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

$securedPassword = ConvertTo-SecureString $env:PASSWORD -AsPlainText -Force;
$Credential = New-Object System.Management.Automation.PSCredential( $env:USERNAME, $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try
{
    &$configName `
        -ConfigurationData $configurationData `
        -Credential $Credential;
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
