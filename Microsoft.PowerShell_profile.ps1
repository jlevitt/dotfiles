### Profile params

$usePoshGit = __USE_POSH_GIT__
$projectsDir = "__PROJECTS_DIR__"
$homeDir = "__HOME_DIR__"
$editor = "__EDITOR__"
$vm_type = "__VM_TYPE__"

### End params

### Cmdlet Aliases

New-Alias which Get-Command

### End cmdlet Aliases

### Environment variables

Set-Location $projectsDir
Remove-Variable -Force HOME
Set-Variable HOME $homeDir
$env:HOMEDRIVE = Split-Path -Path $homeDir -Qualifier
$env:HOMEPATH = Split-Path -Path $homeDir -NoQualifier
$env:GIT_SSH = "$((which plink).Definition)"

### End environment variables

### PS Modules

Import-Module InstallAgent

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

function msave()
{
    mgitp agent save
}

function mpop()
{
    mgitp agent pop
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

function cdmig
{
    cd $projectsDir\agent\src\positronics_agent\v1_0\migrations
}

function edit-profile
{
    & $editor $PROFILE
}

function update-profile
{
    cp $PROFILE $projectsDir\personal\dotfiles\Microsoft.PowerShell_profile.ps1
}

function update-vscode
{
    cp $homeDir\AppData\Roaming\Code\User\settings.json $projectsDir\personal\dotfiles\vscode-user-settings.json
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
    . $projectsDir\agent\env\Scripts\activate.ps1
    $env:PYTHONPATH = "$projectsDir\agent\src;$projectsDir\agent-aloha\src;$projectsDir\agent-beyond\src;$projectsDir\agent-cloud-connect\src;$projectsDir\agent-common\src;$projectsDir\agent-doshii\src;$projectsDir\agent-infogenesis\src;$projectsDir\agent-micros3700\src;$projectsDir\agent-northstar\src;$projectsDir\agent-positouch\src;$projectsDir\agent-squirrel\src;$projectsDir\agent-virtual\src;$projectsDir\debug-helpers\src;"
}

function use-mgit-env()
{
    . $projectsDir\multigit\env\Scripts\activate.ps1
}

if (-not $(ps pageant -ErrorAction SilentlyContinue))
{
    Start-Job -ScriptBlock {
        $mtx = New-Object System.Threading.Mutex($false, "pageant")
        if ($mtx.WaitOne(.5))
        {
            pageant $(Resolve-Path ~\.ssh\id_rsa.ppk)
            $mtx.ReleaseMutex()
        }
    } | Out-Null
}

if (-not $(ps AutoHotkey -ErrorAction SilentlyContinue))
{
    try
    {
        & "$homeDir\default.ahk"
    }
    catch
    {
    }
}

$env:GOPATH = "$projectsDir\go"
$env:TERM='xterm' # http://stefano.salvatori.cl/blog/2017/12/08/how-to-fix-open_stackdumpfile-dumping-stack-trace-to-less-exe-stackdump-gitcygwin/

function Start-Omniprox
{
    Start-Job -Name "Tunnel - Omniprox" -ScriptBlock {
        C:\Users\jlevitt\.raxvm\omniprox.exe
    } | Out-Null
}

function Stop-Omniprox
{
    Get-Job |? { $_.Name -eq "Tunnel - Omniprox" } | Remove-Job -Force
}

function Restart-Omniprox
{
    Stop-Omniprox
    Start-Omniprox
}

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

function Start-MySqlTunnelDev
{
    Start-Job -Name "Tunnel - MySql (Dev)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 3307:localhost:3306 jlevitt
        }
    } | Out-Null
}

function Stop-MySqlTunnelDev
{
    Get-Job -Name "Tunnel - MySql (Dev)" | Remove-Job -Force
}

function Start-MySqlTunnelStage
{
    Start-Job -Name "Tunnel - MySql (Stage)" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 3308:stage-gateway.cgvzdzphnxrt.us-west-2.rds.amazonaws.com:3306 jump-stage
        }
    } | Out-Null
}

function Stop-MySqlTunnelStage
{
    Get-Job -Name "Tunnel - MySql (Stage)" | Remove-Job -Force
}

function Start-SftpTunnel
{
    Start-Job -Name "Tunnel - Sftp" -ScriptBlock {
        while ($true)
        {
            ssh -N -L 2020:jlevitt:22 jlevitt
        }
    } | Out-Null
}

function Stop-SftpTunnel
{
    Get-Job -Name "Tunnel - Sftp" | Remove-Job -Force
}

function Start-DinerwareTunnel
{
    Start-Job -Name "Tunnel - Dinerware" -ScriptBlock {
        while ($true)
        {
            ssh -4 -L22222:127.0.0.1:22222 jlevitt@jump.dev-va1.internal.pos-api.com
        }
    } | Out-Null
}

function Stop-DinerwareTunnel
{
    Get-Job -Name "Tunnel - Dinerware" | Remove-Job -Force
}

function Start-JlevittTunnel
{
    Start-Job -Name "Tunnel - Jlevitt" -ScriptBlock {
        while ($true)
        {
            ssh -M 2023:2024 jlevitt
        }
    } | Out-Null
}

function Stop-JlevittTunnel
{
    Get-Job -Name "Tunnel - Jlevitt" | Remove-Job -Force
}


function Get-DebugBuild
{
    "$([DateTime]::Today.ToString("yy.M.d")).$(Get-Random -Minimum 1 -Maximum 1000)"
}


if ($usePoshGit)
{
    Import-Module Pscx
    Import-Module "C:\Tools\poshgit\dahlbyk-posh-git-a4faccd\src\posh-git.psm1"
}

function Jake()
{
    "Blah"
}
