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
