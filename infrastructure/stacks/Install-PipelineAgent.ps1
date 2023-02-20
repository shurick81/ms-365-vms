switch ($env:MS_365_VMS_PIPELINE_PROVIDER) {
    "Github" {
        try
        {
            Write-Host "Provisioning Github actions agent";
            mkdir c:\actions-runner; cd c:\actions-runner
            $attemptsLeft = 100;
            $resourceUrl = "https://github.com/actions/runner/releases/download/v2.294.0/actions-runner-win-x64-2.294.0.zip"
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
            $currentProgressPreference = $ProgressPreference;
            $ProgressPreference = 'SilentlyContinue';
            Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.294.0/actions-runner-win-x64-2.294.0.zip -OutFile actions-runner-win-x64-2.294.0.zip
            $ProgressPreference = $currentProgressPreference;
            if((Get-FileHash -Path actions-runner-win-x64-2.294.0.zip -Algorithm SHA256).Hash.ToUpper() -ne '22295b3078f7303ffb5ded4894188d85747b1b1a3d88a3eac4d0d076a2f62caa'.ToUpper()){ throw 'Computed checksum did not match' }
            Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory("$PWD/actions-runner-win-x64-2.294.0.zip", "$PWD")
            ./config.cmd --url $env:MS_365_VMS_PIPELINE_URL --token $env:MS_365_VMS_PIPELINE_TOKEN --name (New-Guid).Guid --labels $env:MS_365_VMS_PIPELINE_LABELS --unattended --runasservice
        }
        catch
        {
            Write-Host "$(Get-Date) Exception in the script:"
            $_.Exception.Message
            Throw $_.Exception.Message;
            Exit 1
        }
    }
    "Other" {
        $resourceUrl = "https://vstsagentpackage.azureedge.net/agent/2.179.0/vsts-agent-win-x64-2.179.0.zip";
        $tempFileName = [guid]::NewGuid().Guid + ".zip";
        $tempFilePath = "$env:TEMP\$tempFileName";
        Write-Host "Downloading $resourceUrl to $tempFilePath";
        $currentProgressPreference = $ProgressPreference;
        $ProgressPreference = 'SilentlyContinue';
        Invoke-WebRequest -Uri $resourceUrl -OutFile $tempFilePath;
        $ProgressPreference = $currentProgressPreference;
        
        $dirPath = "c:\AzurePipelineAgent";
        New-Item $dirPath -ItemType Directory -Force | Out-Null;
        Add-Type -AssemblyName System.IO.Compression.FileSystem;
        Write-Host "Unpacking $tempFilePath to $dirPath";
        [System.IO.Compression.ZipFile]::ExtractToDirectory( $tempFilePath, $dirPath );
        
        $agentUniqueSuffix = "ad_crm-win-file-wp-ci-00";
        cd $dirPath
        .\config.cmd remove --auth pat --token $env:AZURE_DEVOPS_PERSONAL_ACCESS_TOKEN
        .\config.cmd --unattended --url https://dev.azure.com/Unionen --auth pat --token $env:AZURE_DEVOPS_PERSONAL_ACCESS_TOKEN --projectName 'Primus' --acceptTeeEula --runAsService --agent "Primus-Platform-$agentUniqueSuffix" --pool Default --replace
        
        
        
        
        
        # Download the gitlab runner binary
        New-Item -Path 'C:\GitLab-Runner' -ItemType Directory
        Set-Location 'C:\GitLab-Runner'
        $currentProgressPreference = $ProgressPreference;
        $ProgressPreference = 'SilentlyContinue';
        Invoke-WebRequest -UseBasicParsing -Uri https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-windows-amd64.exe -OutFile gitlab-runner.exe
        $ProgressPreference = $currentProgressPreference;
        
        # Register a new runner
        .\gitlab-runner.exe register `
          --non-interactive `
          --executor "shell" `
          --url "https://innersource.soprasteria.com/" `
          --registration-token $gitLabRunnerRegistrationToken `
          --description "windows-shell-runner" `
          --tag-list "windows,shell" `
          --run-untagged="false" `
          --locked="false" `
          --docker-privileged
        
        # Install as service
        .\gitlab-runner.exe install
         # Run it
        .\gitlab-runner.exe start
        
        Set-ExecutionPolicy Bypass -Force;
        iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
        choco install -y git
        choco install -y powershell-core
        
        Get-Date;
    }
    Default {}
}