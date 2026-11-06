#Requires -RunAsAdministrator
# Each service runs as its own virtual account (NT SERVICE\<name>), which has no password to expire.
# Entra ID (AzureAD\) accounts can't run services on a machine that isn't domain joined: SCM starts Netlogon first, which fails.

# Machine-specific settings. Edit by hand or delete a line to be re-prompted.
$paramsPath = "$env:USERPROFILE\.services-params.ps1"
$expectedParams = [ordered]@{
    tshHome = "Teleport cert directory the tunnels use (e.g. $env:USERPROFILE\.tsh)"
    omniproxCerts = 'Omniprox cert directory (holds client.crt, client.key, ca.crt)'
}

if (Test-Path $paramsPath)
{
    . $paramsPath
}

$lines = foreach ($name in $expectedParams.Keys)
{
    $value = Get-Variable $name -Scope Script -ValueOnly -ErrorAction SilentlyContinue
    if ($null -eq $value)
    {
        $value = Read-Host $expectedParams[$name]
        Set-Variable $name $value -Scope Script
    }
    "`$$name = '$($value -replace "'", "''")'"
}
$lines | Set-Content $paramsPath
Write-Host "$paramsPath written [OK]"

if (-not (Test-Path $tshHome))
{
    mkdir $tshHome | Out-Null
}

foreach ($file in 'client.crt', 'client.key', 'ca.crt')
{
    if (-not (Test-Path "$omniproxCerts\$file" -PathType Leaf))
    {
        Write-Host "$omniproxCerts\$file not found. Fix omniproxCerts in $paramsPath and run again." -ForegroundColor Red
        exit
    }
}

# Each service's environment, set per service so nothing else sees it. The XMLs reference these as %NAME%.
$teleport = @{ TELEPORT_HOME = $tshHome }
$services = [ordered]@{
    Omniprox = @{ OMNIPROX_CERTS = $omniproxCerts }
    MySqlDevTunnel = $teleport
    SFTPTunnel = $teleport
    RabbitMQAdminTunnel = $teleport
    DashDevTunnel = $teleport
}

foreach ($service in $services.Keys)
{
    $account = "NT SERVICE\$service"
    $environment = $services[$service]
    winsw install $PSScriptRoot\$service\$service.xml
    sc.exe config $service obj= $account | Out-Null
    New-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\$service" Environment -PropertyType MultiString -Value ($environment.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -Force | Out-Null

    # winsw writes its logs next to the XML, as the service account.
    icacls "$PSScriptRoot\$service" /grant "${account}:(OI)(CI)M" | Out-Null
    if ($environment.TELEPORT_HOME)
    {
        # tsh writes here too (keys, known hosts), not just reads.
        icacls $tshHome /grant "${account}:(OI)(CI)M" | Out-Null
    }
    if ($environment.OMNIPROX_CERTS)
    {
        icacls $omniproxCerts /grant "${account}:(OI)(CI)RX" | Out-Null
    }

    gsv $service | sasv
    Write-Host "$service running as $account [OK]"
}
