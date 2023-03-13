#Wait for SQL to becove available
$attemptsLeft = 25;
$SQLServerInstance = $null
Do {
    Try {
        $SQLServerInstance = Get-SqlInstance -ServerInstance $env:SQL_SERVER;
    } Catch {
        $_.Exception.Message;
    }
    if ( $SQLServerInstance ) {
        Write-Host "$( Get-Date ) Successfully reached $env:SQL_SERVER";
    } else {
        Write-Host "$( Get-Date ) Could not reach $env:SQL_SERVER";
    }
    $attemptsLeft--;
} until ( $SQLServerInstance -or ( $attemptsLeft -le 0 ) -or ( Start-Sleep 5 ) )


#Reporting Services Content Managers
$securedPassword = ConvertTo-SecureString $env:CRM_INSTALL_PASSWORD -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmadmin", $securedPassword );
$attemptsLeft = 100;
$resourceUrl = "http://swazsrv00/ReportServer_RSInstance01/ReportService2010.asmx"
$resource = $null
Do {
    Try {
        $resource = Invoke-WebRequest -Uri $resourceUrl -UseBasicParsing -Method Head;
    } Catch {
        $_.Exception.Message;
        $statusCode = $_.Exception.Response.StatusCode;
    }
    if ( $statusCode -eq "Unauthorized" ) {
        Write-Host "$( Get-Date ) Successfully reached $resourceUrl";
    } else {
        Write-Host "$( Get-Date ) Could not reach $resourceUrl";
    }
    $attemptsLeft--;
} until ( $statusCode -eq "Unauthorized" -or ( $attemptsLeft -le 0 ) -or ( Start-Sleep 5 ) )


Grant-RsCatalogItemRole -ReportServerUri http://$env:REPORT_SERVER_HOST_NAME/ReportServer_RSInstance01 -Identity "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmdplsrv" -RoleName "Content Manager" -Path "/" -Credential $CRMInstallAccountCredential;
Grant-RsSystemRole -ReportServerUri http://$env:REPORT_SERVER_HOST_NAME/ReportServer_RSInstance01 -Identity "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmdplsrv" -RoleName "System Administrator" -Credential $CRMInstallAccountCredential;

$configName = "CRMNode"
Write-Host "$(Get-Date) Defining DSC"
Configuration $configName
{
    param(
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName SecurityPolicyDsc -ModuleVersion 2.10.0.0
    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 3.1.1
    Import-DSCResource -ModuleName NetworkingDSC -ModuleVersion 7.4.0.0

    Node $AllNodes.NodeName
    {

        UserRightsAssignment LogonAsAService
        {
            Policy      = "Log_on_as_a_service"
            Identity    = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmvsswrit"
        }

        #Default web site stopped for security reasons
        xWebsite DefaultWebSite
        {
            Name            = "Default Web Site"
            State           = "Stopped"
            ServerAutoStart = $false
        }

        HostsFile "CRMHostEntry"
        {
            HostName    = $env:CRM_HOST_NAME
            IPAddress   = "127.0.0.1"
            Ensure      = "Present"
        }

    }
}
$configurationData = @{ AllNodes = @(
    @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $true; PsDscAllowDomainUser = $true }
) }
Write-Host "$(Get-Date) Compiling DSC"
&$configName `
    -ConfigurationData $configurationData;
Start-DscConfiguration $configName -Verbose -Wait -Force;
Test-DscConfiguration $configName -Verbose;
$result = Test-DscConfiguration $configName -Verbose;
$inDesiredState = $result.InDesiredState;
$failed = $false;
$inDesiredState | % {
    if ( !$_ ) {
        Write-Host "$(Get-Date) Test failed"
        Exit 1;
    }
}

Install-Module Dynamics365Configuration -Force -RequiredVersion 2.25.0;
Save-Dynamics365Resource -Resource $env:MS_365_VMS_DYNAMICS_CRM_BASE -TargetDirectory c:\DynamicsResources\Dynamics365ServerRTM
Save-Dynamics365Resource -Resource $env:MS_365_VMS_DYNAMICS_CRM_UPDATE -TargetDirectory c:\DynamicsResources\Dynamics365ServerUpdate

$securedPassword = ConvertTo-SecureString $env:CRM_INSTALL_PASSWORD -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmadmin", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_SERVICE_PASSWORD -AsPlainText -Force;
$CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsrv", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_DEPLOYMENT_SERVICE_PASSWORD -AsPlainText -Force;
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmdplsrv", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_SANDBOX_SERVICE_PASSWORD -AsPlainText -Force;
$SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsandbox", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_VSS_WRITER_PASSWORD -AsPlainText -Force;
$VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmvsswrit", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_ASYNC_SERVICE_PASSWORD -AsPlainText -Force;
$AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmasync", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_MONITORING_SERVICE_PASSWORD -AsPlainText -Force;
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmmon", $securedPassword );
Invoke-Command $env:COMPUTERNAME`.$env:MS_365_VMS_DOMAIN_NAME -Credential $CRMInstallAccountCredential -Authentication Credssp {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]
        $SQL_SERVER,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [string]
        $MS_365_VMS_DOMAIN_NAME,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $CRMServiceAccountCredential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $DeploymentServiceAccountCredential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $SandboxServiceAccountCredential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $VSSWriterServiceAccountCredential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $AsyncServiceAccountCredential,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [PSCredential]
        $MonitoringServiceAccountCredential
    )
    Write-Host "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce:";
    Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce;
    if ( Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce OneDrive -ErrorAction Ignore ) {
        Remove-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce "OneDrive";
    }
    Write-Host "`$SQL_SERVER:";
    Write-Host $SQL_SERVER;
    Get-Service IISADMIN;
    Install-Dynamics365Server `
        -MediaDir c:\DynamicsResources\Dynamics365ServerRTM `
        -CreateDatabase `
        -ServerRoles FrontEnd, DeploymentAdministration `
        -SqlServer $SQL_SERVER `
        -Patch c:\DynamicsResources\Dynamics365ServerUpdate `
        -PrivUserGroup "CN=CRM01PrivUserGroup,OU=CRM groups 00,DC=$($MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )" `
        -SQLAccessGroup "CN=CRM01SQLAccessGroup,OU=CRM groups 00,DC=$($MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )" `
        -UserGroup "CN=CRM01SQLAccessGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )" `
        -ReportingGroup "CN=CRM01ReportingGroup,OU=CRM groups 00,DC=$($MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )" `
        -PrivReportingGroup "CN=CRM01PrivReportingGroup,OU=CRM groups 00,DC=$($MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )" `
        -AutoGroupManagementOff `
        -CrmServiceAccount $CRMServiceAccountCredential `
        -DeploymentServiceAccount $DeploymentServiceAccountCredential `
        -VSSWriterServiceAccount $VSSWriterServiceAccountCredential `
        -MonitoringServiceAccount $MonitoringServiceAccountCredential `
        -CreateWebSite `
        -WebSitePort 443 `
        -WebSiteUrl https://$env:COMPUTERNAME `
        -LogFilePullToOutput
    Install-Dynamics365Server `
        -MediaDir c:\DynamicsResources\Dynamics365ServerRTM `
        -ServerRoles BackEnd `
        -SqlServer $SQL_SERVER `
        -Patch c:\DynamicsResources\Dynamics365ServerUpdate `
        -SandboxServiceAccount $SandboxServiceAccountCredential `
        -AsyncServiceAccount $AsyncServiceAccountCredential `
        -MonitoringServiceAccount $MonitoringServiceAccountCredential `
        -LogFilePullToOutput
} -ArgumentList $env:SQL_SERVER, $env:MS_365_VMS_DOMAIN_NAME, $CRMServiceAccountCredential, $DeploymentServiceAccountCredential, $SandboxServiceAccountCredential, $VSSWriterServiceAccountCredential, $AsyncServiceAccountCredential, $MonitoringServiceAccountCredential

"$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsrv"


$securedPassword = ConvertTo-SecureString $env:CRM_INSTALL_PASSWORD -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmadmin", $securedPassword );
#Applying post configuration in DSC
$configName = "CRMNodePostConfig"
Write-Host "$(Get-Date) Defining DSC"
Configuration $configName
{
    param(
    )
 
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName FileSystemDsc -ModuleVersion 1.1.1
    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 3.1.1
    Import-DSCResource -ModuleName NetworkingDSC -ModuleVersion 7.4.0.0
 
    Node $AllNodes.NodeName
    {
 
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $false;
        }

        FileSystemAccessRule AssemblyFolderReaders
        {
            Path        = "c:\Program Files\Dynamics 365\Server\bin\assembly"
            Identity    = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsrv"
            Rights      = @('Read')
        }

        FileSystemAccessRule CustomizationImportFolderReaders
        {
            Path        = "C:\Program Files\Dynamics 365\CustomizationImport"
            Identity    = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsrv"
            Rights      = @('Read','Write')
        }

        xWebsite DynamicsWebSite
        {
            Name        = "Microsoft Dynamics CRM"
            State       = "Started"
            BindingInfo = @(
                MSFT_xWebBindingInformation {
                    Protocol            = "HTTPS"
                    Port                = 443
                    CertificateSubject  = $env:CRM_HOST_NAME
                }
                MSFT_xWebBindingInformation {
                    Protocol            = "HTTP"
                    Port                = 80
                    HostName            = "localhost"
                }
            )
        }

        FireWall CRMCommunication
        {
            Name        = "CRMCommunication"
            DisplayName = "CRM Server Communication"
            Ensure      = "Present"
            Enabled     = "True"
            Profile     = 'Domain', 'Private', 'Public'
            Direction   = "InBound"
            LocalPort   = 808
            Protocol    = "TCP"
            Description = "Firewall rule to allow CRM server communication"
        }

    }
}
$configurationData = @{ AllNodes = @(
    @{ NodeName = "$env:COMPUTERNAME.$env:MS_365_VMS_DOMAIN_NAME"; PSDscAllowPlainTextPassword = $true; PsDscAllowDomainUser = $true }
) };
Write-Host "$(Get-Date) Compiling DSC"
&$configName `
    -ConfigurationData $configurationData;
if ( $env:NO_AUTOMATIC_REBOOT -ne "true" ) {
    Set-DscLocalConfigurationManager $configName -Credential $CRMInstallAccountCredential -Verbose -Force;
}
Start-DscConfiguration $configName -Credential $CRMInstallAccountCredential -Verbose -Wait -Force;
Remove-Item $configName -Recurse;

#Updating CRM URLs
Invoke-Command $env:COMPUTERNAME`.$env:MS_365_VMS_DOMAIN_NAME -Credential $CRMInstallAccountCredential -Authentication Credssp {
    param(
        $CRM_HOST_NAME,
        $CRMInstallAccountCredential
    )
    if (-not (Get-PSSnapin -Name Microsoft.Crm.PowerShell -ErrorAction SilentlyContinue))
    {
        Add-PSSnapin Microsoft.Crm.PowerShell
    }
    $WebAddressSettings = Get-CrmSetting -DwsServerUrl "https://$CRM_HOST_NAME" -Credential $CRMInstallAccountCredential -SettingType WebAddressSettings;
    $WebAddressSettings.RootDomainScheme = "https";
    $WebAddressSettings.WebAppRootDomain = "$CRM_HOST_NAME`:443";
    $WebAddressSettings.SdkRootDomain = "$CRM_HOST_NAME`:443";
    $WebAddressSettings.DiscoveryRootDomain = "$CRM_HOST_NAME`:443";
    $WebAddressSettings.DeploymentSdkRootDomain = "$CRM_HOST_NAME`:443";

    Set-CrmSetting -DwsServerUrl "https://$CRM_HOST_NAME" -Credential $CRMInstallAccountCredential -Setting $WebAddressSettings
} -ArgumentList $env:CRM_HOST_NAME, $CRMInstallAccountCredential

Invoke-Command $env:REPORT_SERVER_HOST_NAME -Credential $CRMInstallAccountCredential -Authentication Credssp {
    param(
        $MS_365_VMS_DYNAMICS_CRM_BASE,
        $MS_365_VMS_DYNAMICS_CRM_RE_UPDATE,
        $SQL_SERVER
    )
    Install-Module Dynamics365Configuration -Force -RequiredVersion 2.25.0;
    Save-Dynamics365Resource -Resource $MS_365_VMS_DYNAMICS_CRM_BASE -TargetDirectory c:\DynamicsResources\Dynamics365ServerRTM
    Save-Dynamics365Resource -Resource $MS_365_VMS_DYNAMICS_CRM_RE_UPDATE -TargetDirectory c:\DynamicsResources\Dynamics365ServerReportingExtensionsUpdate
    Install-Dynamics365ReportingExtensions `
        -MediaDir c:\DynamicsResources\Dynamics365ServerRTM\SrsDataConnector `
        -Patch c:\DynamicsResources\Dynamics365ServerReportingExtensionsUpdate `
        -ConfigDBServer $SQL_SERVER `
        -InstanceName RSInstance01 `
        -AutoGroupManagementOff `
        -LogFilePullToOutput;
} -ArgumentList $env:MS_365_VMS_DYNAMICS_CRM_BASE, $env:MS_365_VMS_DYNAMICS_CRM_RE_UPDATE, $env:SQL_SERVER;

if ( $env:MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE ) {
    Write-Host "$(Get-Date) Starting New-CrmOrganization";
    $operationState = Invoke-Command $env:COMPUTERNAME`.$env:MS_365_VMS_DOMAIN_NAME -Credential $CRMInstallAccountCredential -Authentication Credssp {
        param(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $SQL_SERVER,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $REPORT_SERVER_HOST_NAME,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION,
            [Parameter(Mandatory=$true)]
            [ValidateNotNullorEmpty()]
            [string]
            $MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION
        )
        Add-PSSnapin Microsoft.Crm.PowerShell;
        $crmJobId = New-CrmOrganization `
            -Name Contoso `
            -DisplayName "Contoso Ltd." `
            -BaseCurrencyCode $MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE `
            -BaseCurrencyName $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME `
            -BaseCurrencySymbol $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL `
            -BaseCurrencyPrecision $MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION `
            -SqlCollation $MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION `
            -SqlServerName $SQL_SERVER `
            -SrsUrl http://$REPORT_SERVER_HOST_NAME/ReportServer_RSInstance01;
        Write-Host "`$crmJobId: $crmJobId";
        do {
            $operationStatus = Get-CrmOperationStatus -OperationId $crmJobId;
            Write-Host "$(Get-Date) operationStatus.State is $($operationStatus.State). Waiting until CRM installation job is done";
            if ( $operationStatus.State -ne "Failed" ) {
                Sleep 60;
            }
        } while ( $crmJobId -and $operationStatus -and ( $operationStatus.State -ne "Completed" ) -and ( $operationStatus.State -ne "Failed" ) )
        Write-Host '$operationStatus.State:';
        Write-Host $operationStatus.State;
        if ( $operationStatus.State -eq 'Failed' ) {
            $diagOperationStatus = Get-CrmOperationStatus -OperationId $crmJobId -Diag
            Write-Host $diagOperationStatus.ProcessingError.Message;
        }
        Write-Output $operationStatus.State;
    } -ArgumentList $env:SQL_SERVER, $env:REPORT_SERVER_HOST_NAME, $env:MS_365_VMS_DYNAMICS_CRM_BASE_ISO_CURRENCY_CODE, $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_NAME, $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_SYMBOL, $env:MS_365_VMS_DYNAMICS_CRM_BASE_CURRENCY_PRECISION, $env:MS_365_VMS_DYNAMICS_CRM_ORGANIZATION_COLLATION
    if ( $operationState -eq "Completed" ) {
        Write-Host "Test OK";
    } else {
        Write-Host "Exiting 1";
        Exit 1;
    }
}
