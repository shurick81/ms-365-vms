$resourceUrl = "https://dl.eff.org/certbot-beta-installer-win32.exe";
$currentProgressPreference = $ProgressPreference;
$ProgressPreference = 'SilentlyContinue';
$tempFileName = [guid]::NewGuid().Guid + ".exe";
$tempFilePath = "$env:TEMP\$tempFileName";
Do {
    try {
        Write-Host "Downloading $resourceUrl to $tempFilePath";
        Invoke-WebRequest -Uri $resourceUrl -OutFile $tempFilePath;
    }
    catch {
        Write-Host "Download failed:";
        Write-Host $_.Exception.Message;
        Start-Sleep 5;
    }
} until ( Test-Path $tempFilePath )
$ProgressPreference = $currentProgressPreference;

&$tempFilePath /S
Set-ExecutionPolicy Bypass -Force;
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y OpenSSL.Light --version 1.1.1.20181020
