$acceptableDaysToExpiration = 85; #minimal number of days system should work without replacement
New-Item "C:\Certbot\live\$env:PublicHostName" -ItemType Directory -Force | Out-Null;

# Waiting for file share host resolved
$attemptsLeft = 100;
$sslCacheHostName = $env:MS_365_VMS_SSL_CACHE_UNC.Substring(2).Split("\")[0];
$resource = $null
Do {
    $resource = Resolve-DnsName $sslCacheHostName -ErrorAction Ignore;
    if ( $resource ) {
        Write-Host "$( Get-Date ) Successfully reached $sslCacheHostName";
    } else {
        Write-Host "$( Get-Date ) Could not reach $sslCacheHostName";
    }
    $attemptsLeft--;
} until ( $resource -or ( $attemptsLeft -le 0 ) -or ( Start-Sleep 5 ) )
if ( $env:MS_365_VMS_SSL_CACHE_UNC.IndexOf( "\", $env:MS_365_VMS_SSL_CACHE_UNC.IndexOf( "\", 2 ) + 1 ) -ge 0 ) {
    $fileShareUnc = $env:MS_365_VMS_SSL_CACHE_UNC.Substring( 0, $env:MS_365_VMS_SSL_CACHE_UNC.IndexOf( "\", $env:MS_365_VMS_SSL_CACHE_UNC.IndexOf( "\", 2 ) + 1 ) );
} else {
    $fileShareUnc = $env:MS_365_VMS_SSL_CACHE_UNC.Substring( 0, $env:MS_365_VMS_SSL_CACHE_UNC.IndexOf( "\", 2 ) );
}
net use $fileShareUnc $env:MS_365_VMS_SSL_CACHE_PASSWORD /USER:$($env:MS_365_VMS_SSL_CACHE_USERNAME) | Out-Null;
$securedPassword = ConvertTo-SecureString $env:MS_365_VMS_SSL_PFX_PASSWORD -AsPlainText -Force;
$newCertRequired = $false;
$filePath = Join-Path $env:MS_365_VMS_SSL_CACHE_UNC "$env:PublicHostName.pfx";
$existingFile = Get-Item $filePath -ErrorAction Ignore;
if ( $existingFile ) {
    Write-Host "File $filePath found";
    $pfx = New-Object -TypeName "System.Security.Cryptography.X509Certificates.X509Certificate2";
    $pfx.Import( $filePath, $securedPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet );
    if ( $pfx.Thumbprint ) {
        $currentDate = Get-Date;
        $timeToExpirationLeft = New-TimeSpan $currentDate $pfx.NotAfter;
        $daysLeft = $timeToExpirationLeft.Days;
        if ( $daysLeft -lt $acceptableDaysToExpiration ) {
            Write-Host "Certificate will expire in $daysLeft days, which is fewer than $acceptableDaysToExpiration acceptable. A new certificate is required now";
            $newCertRequired = $true;
        } else {
            Write-Host "Certificate will expire in $daysLeft days, which is within $acceptableDaysToExpiration acceptable. A new certificate is not required now";
        }
    } else {
        Write-Host "Could not read certificate from the file";
        $newCertRequired = $true;
    }
} else {
    Write-Host "File $filePath not found";
    $newCertRequired = $true;
}
if ( $newCertRequired ) {
    # Waiting for letsencrypt endpoint reached
    $attemptsLeft = 100;
    $resourceUrl = "https://acme-v02.api.letsencrypt.org/directory"
    $resource = $null
    Do {
        Try {
            $resource = Invoke-WebRequest -Uri $resourceUrl -UseBasicParsing -Method Head;
        } Catch {
            $_.Exception.Message;
        }
        if ( $resource ) {
            Write-Host "$( Get-Date ) Successfully reached $resourceUrl";
        } else {
            Write-Host "$( Get-Date ) Could not reach $resourceUrl";
        }
        $attemptsLeft--;
    } until ( $resource -or ( $attemptsLeft -le 0 ) -or ( Start-Sleep 5 ) )

    New-NetFirewallRule -DisplayName certbot -Direction Inbound -Program "C:\Program Files (x86)\Certbot\Python\python.exe" -LocalPort 80 -Protocol TCP -Action Allow;
    certbot certonly --domain $env:PublicHostName --standalone --register-unsafely-without-email --agree-tos --reuse-key;
    Get-NetFirewallRule -DisplayName certbot | Remove-NetFirewallRule;
    openssl pkcs12 -export -out C:\Certbot\live\$env:PublicHostName\privkey.pfx -inkey C:\Certbot\live\$env:PublicHostName\privkey.pem -in C:\Certbot\live\$env:PublicHostName\cert.pem -passin pass:$env:MS_365_VMS_SSL_PFX_PASSWORD -passout pass:$env:MS_365_VMS_SSL_PFX_PASSWORD
    New-Item $env:MS_365_VMS_SSL_CACHE_UNC -ItemType Directory -Force | Out-Null;
    Copy-Item C:\Certbot\live\$env:PublicHostName\privkey.pfx $filePath;
} else {
    Copy-Item $filePath C:\Certbot\live\$env:PublicHostName\privkey.pfx;
}
$importedCert = Import-PfxCertificate -FilePath C:\Certbot\live\$env:PublicHostName\privkey.pfx -CertStoreLocation Cert:\LocalMachine\My -Password $securedPassword;
( Get-Item $importedCert.PSPath ).FriendlyName = $env:PublicHostName;
