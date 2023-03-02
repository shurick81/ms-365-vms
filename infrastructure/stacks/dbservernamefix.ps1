$retries = 60;
while ((Get-Service 'MSSQL$SQLINSTANCE01').Status -ne "Running") {
    Write-Host 'MSSQL$SQLINSTANCE01 is not running. Waiting.';
    Write-Host "Will retry more $retries times.";
    Sleep 2;
    $retries--;
}
if ((Get-Service 'MSSQL$SQLINSTANCE01').Status -ne "Running") {
    Write-Host 'MSSQL$SQLINSTANCE01 is not running. Exiting.';
    Exit 1;
}
Import-Module SQLPS;
$serverNameResponse = Invoke-Sqlcmd "Select @@SERVERNAME" -ServerInstance "$env:COMPUTERNAME\SQLInstance01";
$serverName = $serverNameResponse.Column1;
Write-Host "Previous server name was $serverName";
$serverNameResponse = Invoke-Sqlcmd ( "sp_dropserver '" + $serverName + "'" ) -ServerInstance "$env:COMPUTERNAME\SQLInstance01";
$serverNameResponse = Invoke-Sqlcmd ( "sp_addserver '$env:COMPUTERNAME\SQLInstance01', 'local'" ) -ServerInstance "$env:COMPUTERNAME\SQLInstance01";
$serverNameResponse = Invoke-Sqlcmd "sp_helpserver" -ServerInstance "$env:COMPUTERNAME\SQLInstance01";
Write-Host "Restarting instance services";
Stop-Service 'MSSQL$SQLInstance01' -Force;
Start-Service 'MSSQL$SQLInstance01';
Start-Service 'SQLAgent$SQLInstance01';

$serverNameResponse = Invoke-Sqlcmd "Select @@SERVERNAME" -ServerInstance "$env:COMPUTERNAME\SQLInstance01";
$serverName = $serverNameResponse.Column1;
Write-Host "New server name is $serverName";
