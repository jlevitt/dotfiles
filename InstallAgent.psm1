function Install-Agent
{
    param(
        $Version,
        $IniPath = (Join-Path $(Resolve-Path "$projectsDir\agent\src\positronics_agent") "*.ini")
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


    Start-Process -NoNewWindow -FilePath $output -ArgumentList "/SKIPACTIVATION" -Wait

    cp $IniPath "C:\Program Files (x86)\POS Agent"

    Get-Service POSAgent | Start-Service

    Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}