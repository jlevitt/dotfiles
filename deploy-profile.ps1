# Machine-specific settings, dot-sourced by the profile. Edit by hand or delete a line to be re-prompted.
$paramsPath = "$env:USERPROFILE\.profile-params.ps1"
$expectedParams = [ordered]@{
    homeDir = 'Home directory'
    usePoshGit = 'Use posh-git? (y/n)'
    projectsDir = 'Projects directory'
    dotfiles = 'Dotfiles directory'
    editor = 'Editor'
    vm_type = 'VM type'
    zoom_room_password = 'Zoom room password'
    github_ssh_key = 'GitHub SSH key file name'
    git_name = 'Git user name'
    git_email = 'Git email'
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
        if ($name -eq 'usePoshGit')
        {
            $value = $value -like 'y*'
        }
        Set-Variable $name $value -Scope Script
    }

    if ($value -is [bool])
    {
        "`$$name = `$$value"
    }
    else
    {
        "`$$name = '$($value -replace "'", "''")'"
    }
}
$lines | Set-Content $paramsPath
Write-Host "$paramsPath written [OK]"

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

if ($vm_type -eq "laptop")
{
    # Default distro and its default user.
    $wslLinuxHome = wsl -- bash -c 'echo $HOME'
    $wslHome = wsl -- bash -c 'wslpath -w ~'
}

# Same as Link-Dotfile, but the link lives inside WSL so Linux tools see a real symlink.
function Link-WslDotfile($target, $link)
{
    $wslTarget = wsl -- wslpath -a ($target -replace '\\', '/')
    wsl -- bash -c "if [ -e '$link' ] && [ ! -L '$link' ]; then mv '$link' '$link.`$(date +%Y%m%d%H%M%S).bak'; fi; ln -sfn '$wslTarget' '$link'"
    Write-Host "WSL $link -> $wslTarget [OK]"
}

Link-Dotfile $dotfiles\Microsoft.PowerShell_profile.ps1 $PROFILE

$gitconfigLocal = "[user]`n  name = $git_name`n  email = $git_email"
$gitconfigLocal | Set-Content $homeDir\.gitconfig.local
Link-Dotfile $dotfiles\.gitconfig $homeDir\.gitconfig
if ($vm_type -eq "laptop")
{
    $gitconfigLocal | Set-Content $wslHome\.gitconfig.local
    Link-WslDotfile $dotfiles\.gitconfig "$wslLinuxHome/.gitconfig"
}

if ($usePoshGit -and -not (Get-Module posh-git))
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

Link-Dotfile $dotfiles\greenshot\Greenshot.ini $homeDir\AppData\Roaming\Greenshot\Greenshot.ini
Link-Dotfile $dotfiles\wmux\config.json $homeDir\.wmux\config.json
Link-Dotfile $dotfiles\wmux\deck-policy.md $homeDir\.wmux\deck-policy.md

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
    foreach ($f in @('.bash_aliases', '.bashrc', '.profile'))
    {
        Link-WslDotfile $dotfiles\wsl\$f "$wslLinuxHome/$f"
    }
}

$gopath = "$projectsDir\go"
[Environment]::SetEnvironmentVariable('GOPATH', $gopath, [EnvironmentVariableTarget]::Machine)
$env:GOPATH = $gopath
if (-not $(Test-Path $gopath))
{
    mkdir $gopath | Out-Null
}
Write-Host "GOPATH written ($gopath) [OK]"

