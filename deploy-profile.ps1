$deployParamsPath = ".deploy-profile-params.xml"
$profileParams = @{}
$expectedParams = @(
    'HOME_DIR',
    'USE_POSH_GIT',
    'PROJECTS_DIR',
    'DOTFILES_DIR',
    'EDITOR',
    'VM_TYPE',
    'ZOOM_ROOM_PASSWORD',
    'GITHUB_SSH_KEY',
    'GIT_EMAIL',
    'GIT_NAME'
)

if (Test-Path $deployParamsPath)
{
   $profileParams = Import-Clixml $deployParamsPath
}

foreach($param in $expectedParams)
{
    if (-not $profileParams.ContainsKey($param))
    {
        $profileParams[$param] = Read-Host "Value for $($param)?"
    }
}

$homeDir = $profileParams["HOME_DIR"]
$dotfiles = $profileParams["DOTFILES_DIR"]
$projects = $profileParams["PROJECTS_DIR"]
$vm_type = $profileParams["VM_TYPE"]

$profileParams | Export-Clixml -Path $deployParamsPath

# From: https://github.com/craibuc/PsTokens/blob/master/Merge-Tokens.ps1
<#
.SYNOPSIS
Replaces tokens in a block of text with a specified value.
.DESCRIPTION
Replaces tokens in a block of text with a specified value.
.PARAMETER template
The block of text that contains text and tokens to be replaced.
.PARAMETER tokens
Token name/value hashtable.
.EXAMPLE
 $content = Get-Content .\template.txt | Merge-Tokens -tokens @{FirstName: 'foo'; LastName: 'bar'}
Pass template to function via pipeline.
#>
function Merge-Tokens() {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory=$True, ValueFromPipeline=$true)]
        [AllowEmptyString()]
        [String] $template,

        [Parameter(Mandatory=$true)]
        [HashTable] $tokens
    )

    # begin { Write-Debug "$($MyInvocation.MyCommand.Name)::Begin" }

    process {
        # Write-Debug "$($MyInvocation.MyCommand.Name)::Process"

        # adapted based on this Stackoverflow answer: http://stackoverflow.com/a/29041580/134367
        try {

            [regex]::Replace( $template, '__(?<tokenName>[\w\.]+)__', {
              # __TOKEN__
              param($match)

              $tokenName = $match.Groups['tokenName'].Value
              Write-Debug $tokenName

              $tokenValue = Invoke-Expression "`$tokens.$tokenName"
              Write-Debug $tokenValue

              if ($tokenValue) {
                # there was a value; return it
                return $tokenValue
              }
              else {
                # non-matching token; return token
                return $match
              }
            })

        }
        catch {
            Write-Error $_
        }

    }

    # end { Write-Debug "$($MyInvocation.MyCommand.Name)::End" }

}

# Point $link at $target in the repo. A real file already at $link is moved aside, never deleted.
function Link-Dotfile($target, $link)
{
    $existing = Get-Item $link -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType -eq 'SymbolicLink')
    {
        if ($existing.Target -eq $target)
        {
            return
        }
        $existing.Delete()
    }
    elseif ($existing)
    {
        $backup = "$link.$(Get-Date -Format yyyyMMddHHmmss).bak"
        Move-Item $link $backup
        Write-Host "  Moved existing $link to $backup"
    }

    $parent = Split-Path $link -Parent
    if (-not (Test-Path $parent))
    {
        mkdir $parent | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path $link -Target $target | Out-Null
    Write-Host "$link -> $target [OK]"
}

$wslDistro = "Ubuntu-20.04"
$wslHome = "\\wsl$\$wslDistro\home\jlevitt"
$wslLinuxHome = "/home/jlevitt"

# Same as Link-Dotfile, but the link lives inside WSL so Linux tools see a real symlink.
function Link-WslDotfile($target, $link)
{
    $wslTarget = wsl -d $wslDistro -- wslpath -a ($target -replace '\\', '/')
    wsl -d $wslDistro -u jlevitt -- bash -c "if [ -e '$link' ] && [ ! -L '$link' ]; then mv '$link' '$link.`$(date +%Y%m%d%H%M%S).bak'; fi; ln -sfn '$wslTarget' '$link'"
    Write-Host "WSL $link -> $wslTarget [OK]"
}

# Machine-specific values stay out of the repo so the tracked files can be linked directly.
Get-Content $dotfiles\profile-params.template.ps1 | Merge-Tokens -tokens $profileParams | Set-Content $env:USERPROFILE\.profile-params.ps1
Write-Host "Profile params written [OK]"
Link-Dotfile $dotfiles\Microsoft.PowerShell_profile.ps1 $PROFILE

Get-Content $dotfiles\gitconfig-local.template | Merge-Tokens -tokens $profileParams | Set-Content $homeDir\.gitconfig.local
Link-Dotfile $dotfiles\.gitconfig $homeDir\.gitconfig
if ($vm_type -eq "laptop")
{
    Get-Content $dotfiles\gitconfig-local.template | Merge-Tokens -tokens $profileParams | Set-Content $wslHome\.gitconfig.local
    Link-WslDotfile $dotfiles\.gitconfig "$wslLinuxHome/.gitconfig"
}

if ($profileParams["USE_POSH_GIT"] -and -not (Get-Module posh-git))
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
    Write-Host "PoshGit module installed [OK]"
}

Link-Dotfile $dotfiles\InstallAgent.psm1 "C:\Program Files\WindowsPowerShell\Modules\InstallAgent\InstallAgent.psm1"

Link-Dotfile $dotfiles\windows\laptop\.vimlayout $homeDir\.vimlayout
Link-Dotfile $dotfiles\.vimrc $homeDir\_vimrc
Link-Dotfile $dotfiles\.ideavimrc $homeDir\.ideavimrc
Link-Dotfile $dotfiles\default.ahk $homeDir\default.ahk
Link-Dotfile $dotfiles\windows\laptop\.bashrc $homeDir\.bashrc
Link-Dotfile $dotfiles\wsl\.wslconfig $homeDir\.wslconfig
Link-Dotfile $dotfiles\starship.toml $homeDir\.config\starship.toml

reg import $dotfiles\TortoiseGit.reg | Out-Null
reg import $dotfiles\TortoiseGitMerge.reg | Out-Null
Write-Host "TortoiseGit settings installed to registry [OK]"

$vscodeDir = "$homeDir\AppData\Roaming\Code\User"
if (Test-Path $vscodeDir)
{
    Link-Dotfile $dotfiles\vscode-user-settings.json $vscodeDir\settings.json
}

$windowsTerminalDir = "$homeDir\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $windowsTerminalDir)
{
    Link-Dotfile $dotfiles\windows\terminal\settings.json $windowsTerminalDir\settings.json
}

$windowsTerminalPreviewDir = "$homeDir\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
if (Test-Path $windowsTerminalPreviewDir)
{
    Link-Dotfile $dotfiles\windows\terminal\settings-preview.json $windowsTerminalPreviewDir\settings.json
}

if ($vm_type -eq "laptop")
{
    foreach ($f in @('.bash_aliases', '.bash_functions', '.bashrc', '.profile'))
    {
        Link-WslDotfile $dotfiles\wsl\$f "$wslLinuxHome/$f"
    }
}

# Claude Code config. Only the tracked, non-secret entries are linked; the rest of ~/.claude stays local.
foreach ($f in @('CLAUDE.md', 'settings.json', 'keybindings.json', 'statusline.sh', 'commands', 'skills'))
{
    if (Test-Path $dotfiles\.claude\$f)
    {
        Link-Dotfile $dotfiles\.claude\$f $homeDir\.claude\$f
    }
}

$gopath = "$projects\go"
[Environment]::SetEnvironmentVariable('GOPATH', $gopath, [EnvironmentVariableTarget]::Machine)
$env:GOPATH = $gopath
if (-not $(Test-Path $gopath))
{
    mkdir $gopath | Out-Null
}
Write-Host "GOPATH written ($gopath) [OK]"

