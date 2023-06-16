$configName = "CommonSMBShare";
Write-Host "$(Get-Date) Defining DSC";
try
{
    Configuration $configName
    {
        param(
        )

        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DSCResource -ModuleName ComputerManagementDsc -ModuleVersion 8.4.0
        Import-DSCResource -ModuleName FileSystemDsc -ModuleVersion 1.1.1

        Node $AllNodes.NodeName
        {

            File CommonSMBSharedDirectory {
                DestinationPath = "f:\common-files"
                Type            = "Directory"
            }

            $fileShareFullAccessIdentities = $env:FILE_SHARE_FULL_ACCESS_IDENTITIES.Split( "," );

            SmbShare 'Common-files'
            {
                Name        = "common-files"
                Path        = "f:\common-files"
                FullAccess  = $fileShareFullAccessIdentities
                DependsOn   = "[File]CommonSMBSharedDirectory"
            }

            $fileShareFullAccessIdentities | % {

                FileSystemAccessRule $_
                {
                    Path        = "f:\common-files"
                    Identity    = $_
                    Rights      = @('FullControl')
                    DependsOn   = "[File]CommonSMBSharedDirectory"
                }

            }

            if ( $env:MS_365_VMS_SHARED_SOURCE_UNC ) {

                $securedPassword = ConvertTo-SecureString $env:MS_365_VMS_SHARED_SOURCE_PASSWORD -AsPlainText -Force
                $MediaShareCredential = New-Object System.Management.Automation.PSCredential( $env:MS_365_VMS_SHARED_SOURCE_USERNAME, $securedPassword );

                File FileShareContents {
                    SourcePath      = $env:MS_365_VMS_SHARED_SOURCE_UNC
                    DestinationPath = $env:TARGET_FILES_PATH
                    Recurse         = $true
                    Type            = "Directory"
                    Credential      = $MediaShareCredential
                    DependsOn       = "[File]CommonSMBSharedDirectory"
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
