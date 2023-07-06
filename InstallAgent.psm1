function programFilesPath
{
    if (Test-Path "C:\Program Files (x86)")
    {
        $programFiles = "C:\Program Files (x86)"
    }
    else
    {
        $programFiles = "C:\Program Files"
    }

    return $programFiles
}

function Install-Agent
{
    param(
        $Version,
        $IniPath = (Join-Path $(Resolve-Path "$projectsDir\anzu\src\positronics_agent") "*.ini")
    )

    $url = "https://s3.amazonaws.com/omnivore-agent-files-candidates/installer/agent_installer-$Version.exe"
    $output = Join-Path $(Resolve-Path "~\Downloads") "agent_installer-$Version.exe"
    $start_time = Get-Date

    if (-not (Test-Path $output))
    {
        try
        {
            # Enable TLS 1.2 (needed for Win7/.NET 3.5). May also need this: https://support.microsoft.com/en-us/topic/update-to-enable-tls-1-1-and-tls-1-2-as-default-secure-protocols-in-winhttp-in-windows-c4bd73d2-31d7-761e-0178-11268bb10392
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType][System.Security.Authentication.SslProtocols]0x00000C00

            $wc = New-Object System.Net.WebClient
            $wc.DownloadFile($url, $output)
        }
        catch [Exception]
        {
            echo $_.Exception|format-list -force
        }
    }

    Start-Process -NoNewWindow -FilePath $output -ArgumentList "/SKIPACTIVATION /SKIPNETTEST /VERYSILENT" -Wait

    cp $IniPath "$(programFilesPath)\POS Agent"

    Get-Service POSAgent | Start-Service

    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function Uninstall-Agent
{
    Write-Output "Uninstalling POSAgent..."

    Start-Process -NoNewWindow -FilePath "$(programFilesPath)\POS Agent\unins000.exe" -ArgumentList "/VERYSILENT" -Wait
}

Export-ModuleMember -function *-*
