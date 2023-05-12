# Following https://docs.microsoft.com/en-us/dynamics365/customerengagement/on-premises/deploy/microsoft-dynamics-365-server-roles#group-membership-requirements ?
$configName = "CRMDomainCustomizations";
Write-Host "$(Get-Date) Defining DSC";
try {
    Configuration $configName
    {
        param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SqlRSAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $TestAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SecondTestAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $CRMInstallAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $CRMServiceAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $DeploymentServiceAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $SandboxServiceAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $VSSWriterServiceAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $AsyncServiceAccountCredential,
            [Parameter(Mandatory = $true)]
            [ValidateNotNullorEmpty()]
            [PSCredential]
            $MonitoringServiceAccountCredential
        )
        Import-DscResource -ModuleName PSDesiredStateConfiguration
        Import-DscResource -ModuleName ActiveDirectoryDsc -ModuleVersion 6.0.1

        Node $AllNodes.NodeName
        {

            ADUser DomainAdminAccountUser
            {
                DomainName              = $env:MS_365_VMS_DOMAIN_NAME
                UserName                = "custom3094857"
                PasswordNeverExpires    = $true
            }

            ADUser SqlRSAccountCredentialUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $SqlRSAccountCredential.GetNetworkCredential().UserName
                Password             = $SqlRSAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser TestUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $TestAccountCredential.GetNetworkCredential().UserName
                Password             = $TestAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser SecondTestUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $SecondTestAccountCredential.GetNetworkCredential().UserName
                Password             = $SecondTestAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser CRMInstallAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $CRMInstallAccountCredential.GetNetworkCredential().UserName
                Password             = $CRMInstallAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser CRMServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $CRMServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $CRMServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser DeploymentServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $DeploymentServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $DeploymentServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser SandboxServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $SandboxServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $SandboxServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser VSSWriterServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $VSSWriterServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $VSSWriterServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser AsyncServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $AsyncServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $AsyncServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADUser MonitoringServiceAccountUser
            {
                DomainName           = $env:MS_365_VMS_DOMAIN_NAME
                UserName             = $MonitoringServiceAccountCredential.GetNetworkCredential().UserName
                Password             = $MonitoringServiceAccountCredential
                PasswordNeverExpires = $true
            }

            ADGroup CRMAdminGroup
            {
                GroupName           = "CRM Administrators 00"
                MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
                DependsOn           = "[ADUser]CRMInstallAccountUser"
            }

            ADObjectPermissionEntry CRMServiceAccountPermissions
            {
                Ensure                             = 'Present'
                Path                               = "CN=$($CRMServiceAccountCredential.GetNetworkCredential().UserName),CN=Users,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\CRM Administrators 00"
                ActiveDirectoryRights              = 'WriteProperty'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADUser]CRMServiceAccountUser", "[ADGroup]CRMAdminGroup"
            }

            #Organization unit with groups pre-provisioned
            ADOrganizationalUnit CRMGroupsOU00
            {
                Name = "CRM groups 00"
                Path = "DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
            }

            ADGroup CRMPrivUserGroup
            {
                GroupName           = "CRM01PrivUserGroup"
                MembersToInclude    = $SqlRSAccountCredential.GetNetworkCredential().UserName, $AsyncServiceAccountCredential.GetNetworkCredential().UserName, $DeploymentServiceAccountCredential.GetNetworkCredential().UserName, $CRMServiceAccountCredential.GetNetworkCredential().UserName, $VSSWriterServiceAccountCredential.GetNetworkCredential().UserName,$CRMInstallAccountCredential.GetNetworkCredential().UserName
                GroupScope          = "Universal"
                Path                = "OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU00", "[ADUser]SqlRSAccountCredentialUser", "[ADUser]AsyncServiceAccountUser", "[ADUser]DeploymentServiceAccountUser", "[ADUser]CRMServiceAccountUser", "[ADUser]VSSWriterServiceAccountUser", "[ADUser]CRMInstallAccountUser"
            }

            ADObjectPermissionEntry CRMPrivUserGroupAccessers00
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01PrivUserGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMPrivUserGroup", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMSQLAccessGroup
            {
                GroupName           = "CRM01SQLAccessGroup"
                MembersToInclude    = $AsyncServiceAccountCredential.GetNetworkCredential().UserName, $DeploymentServiceAccountCredential.GetNetworkCredential().UserName, $MonitoringServiceAccountCredential.GetNetworkCredential().UserName, $CRMServiceAccountCredential.GetNetworkCredential().UserName, $VSSWriterServiceAccountCredential.GetNetworkCredential().UserName
                GroupScope          = "Universal"
                Path                = "OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU00", "[ADUser]AsyncServiceAccountUser", "[ADUser]DeploymentServiceAccountUser", "[ADUser]MonitoringServiceAccountUser", "[ADUser]CRMServiceAccountUser", "[ADUser]VSSWriterServiceAccountUser"
            }

            ADObjectPermissionEntry CRMSQLAccessGroupAccessers00
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01SQLAccessGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMSQLAccessGroup", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMUserGroup
            {
                GroupName        = "CRM01UserGroup"
                Path             = "OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn        = "[ADOrganizationalUnit]CRMGroupsOU00"
            }

            ADObjectPermissionEntry CRMUserGroupAccessers00
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01UserGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMUserGroup", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMReportingGroup
            {
                GroupName           = "CRM01ReportingGroup"
                GroupScope          = "Universal"
                MembersToInclude    = $CRMInstallAccountCredential.GetNetworkCredential().UserName
                Path                = "OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU00"
            }

            ADObjectPermissionEntry CRMReportingGroupAccessers00
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01ReportingGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMReportingGroup", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMPrivReportingGroup
            {
                GroupName           = "CRM01PrivReportingGroup"
                GroupScope          = "Universal"
                MembersToInclude    = $SqlRSAccountCredential.GetNetworkCredential().UserName
                Path                = "OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn           = "[ADOrganizationalUnit]CRMGroupsOU00", "[ADUser]SqlRSAccountCredentialUser"
            }

            ADObjectPermissionEntry CRMPrivReportingGroupAccessers00
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01PrivReportingGroup,OU=CRM groups 00,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMPrivReportingGroup", "[ADUser]DeploymentServiceAccountUser"
            }

            #Organization unit with no groups but full permissions
            ADOrganizationalUnit CRMGroupsOU01
            {
                Name = "CRM groups 01"
                Path = "DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
            }

            ADObjectPermissionEntry OUPermissions
            {
                Ensure                             = 'Present'
                Path                               = "OU=CRM groups 01,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\CRM Administrators 00"
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADOrganizationalUnit]CRMGroupsOU01", "[ADGroup]CRMAdminGroup"
            }

            #Organization unit with pre-created groups without members, but with full permissions
            ADOrganizationalUnit CRMGroupsOU02
            {
                Name = "CRM groups 02"
                Path = "DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
            }

            ADObjectPermissionEntry OUPermissions02
            {
                Ensure                              = 'Present'
                Path                                = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                   = "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\CRM Administrators 00"
                ActiveDirectoryRights               = 'GenericAll'
                AccessControlType                   = 'Allow'
                ObjectType                          = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance  = 'All'
                InheritedObjectType                 = '00000000-0000-0000-0000-000000000000'
                DependsOn                           = "[ADOrganizationalUnit]CRMGroupsOU02", "[ADGroup]CRMAdminGroup"
            }

            ADGroup CRMPrivUserGroup02
            {
                GroupName   = "CRM01PrivUserGroup02"
                GroupScope  = "Universal"
                Path        = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU02"
            }

            ADObjectPermissionEntry CRMPrivUserGroupAccessers02
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01PrivUserGroup02,OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMPrivUserGroup02", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMSQLAccessGroup02
            {
                GroupName   = "CRM01SQLAccessGroup02"
                GroupScope  = "Universal"
                Path        = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU02"
            }

            ADObjectPermissionEntry CRMSQLAccessGroupAccessers02
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01SQLAccessGroup02,OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMSQLAccessGroup02", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMUserGroup02
            {
                GroupName   = "CRM01UserGroup02"
                Path        = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU02"
            }

            ADObjectPermissionEntry CRMUserGroupAccessers02
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01UserGroup02,OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMUserGroup02", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMReportingGroup02
            {
                GroupName   = "CRM01ReportingGroup02"
                GroupScope  = "Universal"
                Path        = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU02"
            }

            ADObjectPermissionEntry CRMReportingGroupAccessers02
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01ReportingGroup02,OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMReportingGroup02", "[ADUser]DeploymentServiceAccountUser"
            }

            ADGroup CRMPrivReportingGroup02
            {
                GroupName   = "CRM01PrivReportingGroup02"
                GroupScope  = "Universal"
                Path        = "OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                DependsOn   = "[ADOrganizationalUnit]CRMGroupsOU02"
            }

            ADObjectPermissionEntry CRMPrivReportingGroupAccessers02
            {
                Ensure                             = 'Present'
                Path                               = "CN=CRM01PrivReportingGroup02,OU=CRM groups 02,DC=$($env:MS_365_VMS_DOMAIN_NAME.Replace( ".", ",DC=" ) )"
                IdentityReference                  = $DeploymentServiceAccountCredential.UserName
                ActiveDirectoryRights              = 'GenericAll'
                AccessControlType                  = 'Allow'
                ObjectType                         = '00000000-0000-0000-0000-000000000000'
                ActiveDirectorySecurityInheritance = 'All'
                InheritedObjectType                = '00000000-0000-0000-0000-000000000000'
                DependsOn                          = "[ADGroup]CRMPrivReportingGroup02", "[ADUser]DeploymentServiceAccountUser"
            }

        }
    }
}
catch {
    Write-Host "$(Get-Date) Exception in defining DCS:";
    $_.Exception.Message;
    Exit 1;
}
$configurationData = @{ AllNodes = @(
        @{ NodeName = $env:COMPUTERNAME; PSDscAllowPlainTextPassword = $True; PsDscAllowDomainUser = $True }
    ) 
}

$securedPassword = ConvertTo-SecureString $env:RS_SERVICE_PASSWORD -AsPlainText -Force
$SqlRSAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_ssrs", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_TEST_1_PASSWORD -AsPlainText -Force
$TestAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_testuser1", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_TEST_2_PASSWORD -AsPlainText -Force
$SecondTestAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_testuser2", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_INSTALL_PASSWORD -AsPlainText -Force
$CRMInstallAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmadmin", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_SERVICE_PASSWORD -AsPlainText -Force
$CRMServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsrv", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_DEPLOYMENT_SERVICE_PASSWORD -AsPlainText -Force
$DeploymentServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmdplsrv", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_SANDBOX_SERVICE_PASSWORD -AsPlainText -Force
$SandboxServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmsandbox", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_VSS_WRITER_PASSWORD -AsPlainText -Force
$VSSWriterServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmvsswrit", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_ASYNC_SERVICE_PASSWORD -AsPlainText -Force
$AsyncServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmasync", $securedPassword );
$securedPassword = ConvertTo-SecureString $env:CRM_MONITORING_SERVICE_PASSWORD -AsPlainText -Force
$MonitoringServiceAccountCredential = New-Object System.Management.Automation.PSCredential( "$($env:MS_365_VMS_DOMAIN_NAME.Split( "." )[0].ToUpper())\_crmmon", $securedPassword );
Write-Host "$(Get-Date) Compiling DSC";
try {
    &$configName `
        -ConfigurationData $configurationData `
        -SqlRSAccountCredential $SqlRSAccountCredential `
        -TestAccountCredential $TestAccountCredential `
        -SecondTestAccountCredential $SecondTestAccountCredential `
        -CRMInstallAccountCredential $CRMInstallAccountCredential `
        -CRMServiceAccountCredential $CRMServiceAccountCredential `
        -DeploymentServiceAccountCredential $DeploymentServiceAccountCredential `
        -SandboxServiceAccountCredential $SandboxServiceAccountCredential `
        -VSSWriterServiceAccountCredential $VSSWriterServiceAccountCredential `
        -AsyncServiceAccountCredential $AsyncServiceAccountCredential `
        -MonitoringServiceAccountCredential $MonitoringServiceAccountCredential;
}
catch {
    Write-Host "$(Get-Date) Exception in compiling DCS:";
    $_.Exception.Message;
    Exit 1;
}
Write-Host "$(Get-Date) Starting DSC";
try {
    Start-DscConfiguration $configName -Verbose -Wait -Force;
}
catch {
    Write-Host "$(Get-Date) Exception in starting DCS:";
    $_.Exception.Message;
    Exit 1;
}
if ( $env:VMDEVOPSSTARTER_NODSCTEST -ne "TRUE" ) {
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
}
else {
    Write-Host "$(Get-Date) Skipping tests";
}
Exit 0;
