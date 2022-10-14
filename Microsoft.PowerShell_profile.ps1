### Profile params

$usePoshGit = __USE_POSH_GIT__
$projectsDir = "__PROJECTS_DIR__"
$dotfiles = "__DOTFILES_DIR__"
$homeDir = "__HOME_DIR__"
$editor = "__EDITOR__"
$vm_type = "__VM_TYPE__"
$zoom_room_password = "__ZOOM_ROOM_PASSWORD__"
$github_ssh_key = "__GITHUB_SSH_KEY__"

### End params

### Cmdlet Aliases

New-Alias which Get-Command
New-Alias rsv Restart-Service
New-Alias pc Get-Clipboard

### End cmdlet Aliases

### Environment variables

Set-Location $projectsDir
Remove-Variable -Force HOME -ErrorAction SilentlyContinue
Set-Variable HOME $homeDir
$env:HOMEDRIVE = Split-Path -Path $homeDir -Qualifier
$env:HOMEPATH = Split-Path -Path $homeDir -NoQualifier
$env:GIT_SSH = "$((which plink).Definition)"

### End environment variables

### PS Modules

Import-Module InstallAgent

if ($usePoshGit)
{
    Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1'
}


### End PS Modules

### Git helpers
function Grepout($pattern)
{
    git checkout $(git branch | grep $pattern).Trim()
}

Set-Alias grout Grepout

function DeleteMergedLocal()
{
    git branch --merged | grep -v "\*" | grep -v "master" |% { git branch -d $_.Trim() }
}

Set-Alias dml DeleteMergedLocal

function ViewMergedLocal()
{
    git branch --merged | grep -v "\*" | grep -v "master"
}

Set-Alias vml ViewMergedLocal

function Copy-Branch($pattern)
{
    $(git br | grep $pattern).Replace("*", "").Trim() | clip
}
Set-Alias cbr Copy-Branch

function git-pop-ini
{
    git pop
    git skip src/positronics_agent/general.ini
    git skip src/positronics_agent/site.ini
}

function git-stash-ini
{
    git unskip src/positronics_agent/general.ini
    git unskip src/positronics_agent/site.ini
    git save
}

### End git helpers

### Aloha specific

if ($vm_type -eq "aloha")
{
    function kiber
    {
        ps *iber* | kill
    }

    function copy-como()
    {
        kiber
        sleep 3
        copy C:\Users\aloha\dev\como-aloha\Artifacts\*.* C:\BootDrv\Aloha\BIN
        copy C:\Users\aloha\dev\como-ui\Artifacts\*.* C:\Como\ComoApp
        $env:TERM=17
        C:\BootDrv\Aloha\IBERCFG.BAT
        $env:TERM="xterm"
    }

    function copy-ui()
    {
        copy C:\Users\aloha\dev\como-ui\Artifacts\*.* C:\Como\ComoApp
    }

    $env:TERM='xterm' # http://stefano.salvatori.cl/blog/2017/12/08/how-to-fix-open_stackdumpfile-dumping-stack-trace-to-less-exe-stackdump-gitcygwin/

    function aloha-cli
    {
        $env:TERM = "5"
        & $anzu\scripts\aloha\AlohaCLI\AlohaCLITest\bin\Debug\AlohaCLITest.exe
        $env:TERM = "xterm"
    }
}

### End Aloha specific

### POSitouch specific

function Remove-Caches()
{
    rm 'C:\ProgramData\POS Agent\db\cache_gEc4Rcex_v1-0.db' -ErrorAction SilentlyContinue; rm 'C:\ProgramData\POS Agent\posi\positouch_0.db' -ErrorAction SilentlyContinue;
}

### End POSitouch specific



function Coalesce($a, $b)
{
    if ($a -ne $null)
    {
        $a
    }
    else
    {
        $b
    }
}

function Select-Zip {
    [CmdletBinding()]
    Param(
        $First,
        $Second,
        $ResultSelector = { ,$args }
    )

    [System.Linq.Enumerable]::Zip($First, $Second, [Func[Object, Object, Object[]]]$ResultSelector)
}

#See possible commands here: https://tortoisegit.org/docs/tortoisegit/tgit-automation.html
function TortoiseGit($command, $path)
{
    if (-not $path)
    {
        $path = "."
    }
    & "C:\Program Files\TortoiseGit\bin\TortoiseGitProc.exe" /command:$command /path:$path
}

Set-Alias tgit TortoiseGit

function ShowUnpushedCommits
{
    git branch |% { $_.Substring(2) } |% { git log origin/$_..$_ }
}

Set-Alias git-show-unpushed-commits ShowUnpushedCommits

function ShowDeletions($rangeSpecification)
{
    git log $rangeSpecification --shortstat | sls "([\d]+) deletions" |% { $_.Matches } |% { $_.groups[1].value } | Measure-Object -Sum
}

Set-Alias git-deletions ShowDeletions

function GitChangeLog($rangeSpecification)
{
    git log --merges --grep="pull request" --pretty=format:'%C(yellow)%h%Creset - %s%n  %an %Cgreen(%cr)%C(bold blue)%d%Creset%n' $rangeSpecification
}

Set-Alias git-cl GitChangeLog

function KillSite($keep)
{
    Get-Process iisexpress |? { -Not $keep.Contains($_.Id) } | Stop-Process
}

Set-Alias ks KillSite

function DeleteBinaries($path)
{
    if (-not $path)
    {
        throw "You must supply a path"
    }
    gci $path -Recurse -Include *.exe,*.pdb,*.dll | Remove-Item
}

Set-Alias delbin DeleteBinaries

function OpenSolutions($path)
{
    $path = ?? $path "."
    . $(ls $path\*.sln)
}

Set-Alias sln OpenSolutions

function OpenAtom
{
    atom .
}

Set-Alias atm OpenAtom

function nunit($path, $Version = "cwd")
{
    $dll = $path
    $dllName = $path | Split-Path -Leaf
    if (-not $path.EndsWith(".dll"))
    {
    $dll = Join-Path $path "bin\debug\$dllName.dll" -Resolve -ErrorAction SilentlyContinue
    }

    if (-not $dll)
    {
    $dll = Join-Path $path "bin\Development\$dllName.dll" -Resolve -ErrorAction SilentlyContinue
    }

    switch($version)
    {
    "cwd" { . $(gci *tools*\NUnit\nunit-x86.exe) $dll }
    "3.6" { . "C:\Program Files\NUnit-Gui-0.3\nunit-gui.exe" $dll }
    }
}

function ChangeDirProjects
{
    cd $projectsDir
}

Set-Alias projects ChangeDirProjects

function ChangeDirHaskell
{
    cd $projectsDir\personal\haskell\course\4
}

Set-Alias hk ChangeDirHaskellKatas

function ChangeDirHaskellKatas
{
    cd $projectsDir\personal\haskell-katas
}

Set-Alias hs ChangeDirHaskell

$infra = "$projectsDir\infra"
function infra
{
    cd $infra
}

$giganto = "$projectsDir\giganto"
function giganto
{
    cd $giganto
}

$anzu = "$projectsDir\anzu"
function anzu
{
    cd $anzu
}

$migrations = "$projectsDir\anzu\src\positronics_agent\v1_0\migrations"
function migrations
{
    cd $migrations
}

function dotfiles
{
    cd $dotfiles
}

$titanoboa = "$projectsDir\titanoboa"
function titanoboa
{
    cd $titanoboa
}

$personal = "$projectsDir\personal"
function personal
{
    cd $personal
}

$scripts = "$personal\scripts"
function scripts
{
    cd $scripts
}

$agentDevConfig = "$projectsDir\agent-dev-config"
function agent-dev-config
{
    pushd $agentDevConfig
}

function edit-profile
{
    & $editor $PROFILE
}

function Sync-Dotfiles
{
    cp $PROFILE $dotfiles\Microsoft.PowerShell_profile.ps1
    cp ~\default.ahk $dotfiles\default.akh
    cp $homeDir\.vimlayout $dotfiles\windows\laptop\.vimlayout -Force
    cp $homeDir\_vimrc $dotfiles\.vimrc -Force
    reg export "HKCU\Software\TortoiseGit" $dotfiles\TortoiseGit.reg /y | Out-Null
    reg export "HKCU\Software\TortoiseGitMerge" $dotfiles\TortoiseGitMerge.reg /y | Out-Null

    $vscodePath = "$homeDir\AppData\Roaming\Code\User\settings.json"
    if (Test-Path $vscodePath)
    {
        cp $homeDir\AppData\Roaming\Code\User\settings.json $dotfiles\vscode-user-settings.json
    }

    $windowsTerminalPath = "~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $windowsTerminalPath)
    {
        cp $windowsTerminalPath $dotfiles\windows\terminal\settings.json
    }

    $windowsTerminalPreviewPath = "~\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    if (Test-Path $windowsTerminalPreviewPath)
    {
        cp $windowsTerminalPreviewPath $dotfiles\windows\terminal\settings-preview.json
    }

    tgit commit $dotfiles
}

function edit($path)
{
    & $editor $path
}

function pull
{
    git save
    git pullr
    git pop
}

function off
{
    Stop-Computer -Force -AsJob
}

function Get-UnixNow {
   $utc = [DateTime]::UTCNow
   $timespan = $utc - ([datetime]'1/1/1970')
   [Math]::Round($timespan.TotalSeconds)
}


function Convert-FromUnixdate ($unixDate) {
   $utc = ([datetime]'1/1/1970').AddSeconds($unixDate)
   $utc.ToLocalTime()
}

function Convert-ToUnixdate ($datetime) {
   $utc = ([DateTime]$datetime).ToUniversalTime()
   $timespan = $utc - ([datetime]'1/1/1970')
   $timespan.TotalSeconds
}

function ConvertPst-FromUnixdate ($unixDate) {
   $utc = ([datetime]'1/1/1970').AddSeconds($unixDate)
   $pstInfo = [TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
   [TimeZoneInfo]::ConvertTimeFromUtc($utc, $pstInfo)
}

function ConvertPst-ToUnixdate ($datetime) {
   $pstInfo = [TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
   $utc = [TimeZoneInfo]::ConvertTimeToUtc([DateTime]$datetime, $pstInfo)
   $timespan = $utc - ([datetime]'1/1/1970')
   $timespan.TotalSeconds
}

function Convert-FromJsonNetDate ($date) {
   $utc = ([datetime]'1/1/1970').AddMilliseconds($date)
   $utc.ToLocalTime()
}

function Grep-AliasCommand($pattern)
{
    Get-Alias |? { $_.ReferencedCommand.Name.Contains($pattern) }
}

New-Alias python27 C:\Tools\python2\python.exe
New-Alias python36 C:\Python36\python.exe

function use-agent-env()
{
    . $projectsDir\anzu\env\Scripts\activate.ps1
    $env:PYTHONPATH = "$projectsDir\anzu\src;$projectsDir\anzu\tests;"
}

function use-mgit-env()
{
    . $projectsDir\multigit\env\Scripts\activate.ps1
}

# One time setup - only one profile script can enter this block at a time
$mtx = New-Object System.Threading.Mutex($false, "ps-profile")

if ($mtx.WaitOne(0))
{
    try
    {
        if (-not $(ps pageant -ErrorAction SilentlyContinue))
        {
            pageant $(Resolve-Path ~\.ssh\$github_ssh_key)
        }

        if (-not $(ps AutoHotkey -ErrorAction SilentlyContinue))
        {
            # Ignore if file not found.
            try
            {
                & "$homeDir\default.ahk"
            }
            catch
            {
            }
        }
    }
    finally
    {
        $mtx.ReleaseMutex()
    }
}


$env:GOPATH = "$projectsDir\go"
$env:TERM='xterm' # http://stefano.salvatori.cl/blog/2017/12/08/how-to-fix-open_stackdumpfile-dumping-stack-trace-to-less-exe-stackdump-gitcygwin/


function Start-AzureHVTunnels
{
    Start-Job -Name "Tunnel - Azure: jlevitt-POSi641-20180103" -ScriptBlock {
        C:\Users\jlevitt\.raxvm\omniprox.exe -host router.azure.pos-api.com -port 10000
    } | Out-Null
}

function Stop-AzureHVTunnels
{
    Get-Job |? { $_.Name.Contains("Tunnel - Azure:") } | Remove-Job -Force
}

function Start-AwsLinuxTest1Tunnel
{
    Start-Job -Name "Tunnel - AwsLinuxTest1" -ScriptBlock {
        while ($true)
        {
            ssh -i C:\Users\jlevitt\.ssh\aws-linux-test1.pem ec2-user@ec2-52-14-31-241.us-east-2.compute.amazonaws.com
        }
    } | Out-Null
}

function Stop-AwsLinuxTest1Tunnel
{
    Get-Job -Name "Tunnel - AwsLinuxTest1" | Remove-Job -Force
}

function Start-MySqlTunnelDevCloudPOS
{
    Start-Job -Name "Tunnel - MySql (DevCloudPOS)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 8765:localhost:3310 jlevitt
        }
    } | Out-Null
}

function Stop-MySqlTunnelDevCloudPOS
{
    Get-Job -Name "Tunnel - MySql (DevCloudPOS)" | Remove-Job -Force
}

function Start-MySqlTunnelStageBrink
{
    Start-Job -Name "Tunnel - MySql (Stage - Brink)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 3308:stage-gateway.cgvzdzphnxrt.us-west-2.rds.amazonaws.com:3306 jump-stage
        }
    } | Out-Null
}

function Stop-MySqlTunnelStageBrink
{
    Get-Job -Name "Tunnel - MySql (Stage - Brink)" | Remove-Job -Force
}

function Start-MySqlTunnelStagePositronics
{
    # Make sure tunnel is running on jump-stage as well:
    # In a screen: ssh -4L 3308:10.0.68.111:3306 database1
    Start-Job -Name "Tunnel - MySql (Stage - Positronics)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 3309:127.0.0.1:3309 jump-stage
        }
    } | Out-Null
}

function Stop-MySqlTunnelStagePositronics
{
    Get-Job -Name "Tunnel - MySql (Stage - Positronics)" | Remove-Job -Force
}

function Start-MySqlTunnelStageAgentMaster
{
    # Make sure tunnel is running on jump-stage as well:
    # In a screen: ssh -4L 3310:10.0.101.72:3310 database1
    Start-Job -Name "Tunnel - MySql (Stage - Agent Master)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 3310:127.0.0.1:3310 jump-stage
        }
    } | Out-Null
}

function Stop-MySqlTunnelStageAgentMaster
{
    Get-Job -Name "Tunnel - MySql (Stage - Agent Master)" | Remove-Job -Force
}

function Start-DelveTunnel
{
    Start-Job -Name "Tunnel - Delve" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 2345:jlevitt:2345 jlevitt
        }
    } | Out-Null
}

function Stop-DelveTunnel
{
    Get-Job -Name "Tunnel - Delve" | Remove-Job -Force
}

function Start-MarketPlaceUITunnelDev
{
    Start-Job -Name "Tunnel - MarketPlaceUI (Dev)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 6501:localhost:6501 jlevitt
        }
    } | Out-Null
}

function Stop-MarketPlaceUITunnelDev
{
    Get-Job -Name "Tunnel - MarketPlaceUI (Dev)" | Remove-Job -Force
}

function Get-DebugBuild
{
    "$([DateTime]::Today.ToString("yy.M.d")).$(Get-Random -Minimum 1 -Maximum 1000)"
}

function Decode-Html
{
    [System.Net.WebUtility]::HtmlDecode($input)
}

function Encode-Html
{
    [System.Net.WebUtility]::HtmlEncode($input)
}

function Format-Xml
{
    $input | xmllint --format -
}

function zoom()
{
    "https://omnivore.zoom.us/my/omnijake?pwd=$zoom_room_password" | clip
}

function retro
{
    start "https://omnivoreio.atlassian.net/issues/?filter=10013"
}

function join
{
    param(
        $prefix = $null,
        $postfix = $null,
        $sep = ", ",
        [switch]$surround = $false
    )

    $lines = $input -Split "`r`n" |? { -not [string]::IsNullOrWhiteSpace($_) }

    $joined = [string]::Join($sep, $($lines |% { "$prefix$_$postfix" }) )

    if ($surround)
    {
        $joined = "($joined)"
    }

    $joined
}

# Fix Network Shares
function rlm
{
    gsv LanMan* | Restart-Service -Force
}

function Get-SiteIni
{
    $activeResponse = $(gcb)
    $siteIni = $activeResponse.Replace('"', '').Replace(' ', '').Replace(',', '').Replace(':', ' = ').Replace('host', 'Host').Replace('password', 'Password').Replace('port', 'Port').Replace('username', 'Username').Replace('bridge', 'Bridge')

    if ($($activeResponse |? { $_.Contains("dev-ca1.internal.pos-api.com") }).Count -gt 0)
    {
        $siteIni = $siteIni.Replace('443', '8443')
    }

    $siteIni # | clip
}

function Sync-AgentData
{
    [CmdletBinding()]
    Param(
        [ValidateSet('menu', 'tickets_sync', 'labor', 'discounts', 'service_charges', 'basic_types', 'layout')]
        $DataType = $null
    )

    if ($DataType)
    {
        sqlite3 'C:\ProgramData\POS Agent\db\agent_master.db' "update store_scheduled_tasks set start_time=null, next_run=CURRENT_TIMESTAMP where name = '$DataType';"
    }
    else
    {
        sqlite3 'C:\ProgramData\POS Agent\db\agent_master.db' "update store_scheduled_tasks set start_time=null, next_run=CURRENT_TIMESTAMP;"
    }
}

function Restore-Ini
{
    git unskip $anzu\src\positronics_agent\general.ini
    git restore $anzu\src\positronics_agent\general.ini

    git unskip $anzu\src\positronics_agent\site.ini
    git restore $anzu\src\positronics_agent\site.ini
}

function Link-Ini
{
    pushd $anzu
    rm $anzu\src\positronics_agent\general.ini
    New-Item -Type SymbolicLink -Path $anzu\src\positronics_agent\general.ini -Target $agentDevConfig\general.ini
    git skip $anzu\src\positronics_agent\general.ini

    rm $anzu\src\positronics_agent\site.ini
    New-Item -Type SymbolicLink -Path $anzu\src\positronics_agent\site.ini -Target $agentDevConfig\site.ini
    git skip $anzu\src\positronics_agent\site.ini
    popd
}

function Activate-Venv
{
    . .\env\scripts\activate.ps1
}
