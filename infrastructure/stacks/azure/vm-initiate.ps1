Start-Transcript -Path c:\vm-initiate.ps1.Log;
if ( !$RemoteHostName ) { $RemoteHostName = ( Invoke-RestMethod https://api.ipify.org?format=json ).ip }
Write-Host "Setup WinRM for $RemoteHostName and $ComputerName";

$Cert = New-SelfSignedCertificate -DnsName $RemoteHostName, $ComputerName `
    -CertStoreLocation "cert:\LocalMachine\My";

$Cert | Out-String;

$Thumbprint = $Cert.Thumbprint;

Write-Host "Enable HTTPS in WinRM";
$WinRmHttps = "@{Hostname=`"$RemoteHostName`"; CertificateThumbprint=`"$Thumbprint`"}";
winrm create winrm/config/Listener?Address=*+Transport=HTTPS $WinRmHttps;

Write-Host "Set Basic Auth in WinRM";
$WinRmBasic = "@{Basic=`"true`"}";
winrm set winrm/config/service/Auth $WinRmBasic;

Write-Host "Open Firewall Port";
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=$WinRmPort;

Stop-Transcript;