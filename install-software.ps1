#Requires -RunAsAdministrator
# New machine setup. Run before deploy-profile.ps1, from an admin Windows PowerShell:
#   Set-ExecutionPolicy Bypass -Scope Process -Force; .\install-software.ps1 -Work
# packages\both.json always installs; -Work and -Personal add their lists.
param(
    [switch]$Work,
    [switch]$Personal
)

function Update-SessionPath
{
    foreach ($name in 'NVM_HOME', 'NVM_SYMLINK')
    {
        $value = [Environment]::GetEnvironmentVariable($name, 'Machine')
        if (-not $value)
        {
            $value = [Environment]::GetEnvironmentVariable($name, 'User')
        }
        if ($value)
        {
            Set-Item "env:$name" $value
        }
    }
    $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}

# Windows settings
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock AllowDevelopmentWithoutDevLicense 1  # Developer Mode, for symlinks
Set-ItemProperty HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem LongPathsEnabled 1
Set-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced HideFileExt 0
Set-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced Hidden 1
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# winget
$lists = @('both')
if ($Work)
{
    $lists += 'work'
}
if ($Personal)
{
    $lists += 'personal'
}
foreach ($list in $lists)
{
    winget import "$PSScriptRoot\packages\$list.json" --accept-package-agreements --accept-source-agreements --ignore-unavailable
}

if ($Work)
{
    winget install --id Microsoft.VisualStudio.Professional -e --accept-package-agreements --override '--wait --quiet --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack'
    # 32-bit 3.13 alongside the default 3.14 from both.json.
    winget install --id Python.Python.3.13 -e --architecture x86 --accept-package-agreements
}

# Chocolatey, for what winget doesn't have
if (-not (Get-Command choco -ErrorAction SilentlyContinue))
{
    Invoke-RestMethod https://community.chocolatey.org/install.ps1 | Invoke-Expression
}
choco install cascadia-code-nerd-font -y
if ($Work)
{
    choco install baretail -y
    choco install rabbitmqadmin -y
    choco install mingw -y  # gcc for building the Go Agent (cgo)
    choco install amazon-ecr-credential-helper -y
    choco install terraform --version 1.9.5 -y
    choco pin add --name=terraform
}
if ($Personal)
{
    choco install haskell-dev -y
}

Update-SessionPath

if ($Work)
{
    Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName IIS-WebServerRole, IIS-ManagementConsole, IIS-ASPNET45, TelnetClient | Out-Null

    Install-Module Az, AWS.Tools.Installer, PsIni, DotNetVersionLister -Scope CurrentUser -Force -Repository PSGallery

    nvm install lts
    nvm use lts
    npm install -g yarn@1

    New-Item -ItemType Directory 'C:\Program Files\WinSW' -Force | Out-Null
    Invoke-WebRequest https://github.com/winsw/winsw/releases/download/v3.0.0-alpha.10/WinSW-x64.exe -OutFile 'C:\Program Files\WinSW\WinSW.exe'
    $machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    if ($machinePath -notlike '*C:\Program Files\WinSW*')
    {
        [Environment]::SetEnvironmentVariable('Path', "$machinePath;C:\Program Files\WinSW", 'Machine')
    }
    Write-Host "Optional next step: install the tunnel services with $PSScriptRoot\windows\services\install-services.ps1 (prompts for your Windows credentials)."
}

Invoke-WebRequest -UseBasicParsing https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | New-Item $HOME\vimfiles\autoload\plug.vim -Force | Out-Null

wsl --status *> $null
if ($LASTEXITCODE -ne 0)
{
    wsl --install
}

<#
Manual

- [ ] Reboot, then run deploy-profile.ps1
- [ ] vim +PlugInstall +qall (after deploy links _vimrc)
- [ ] JetBrains Toolbox: GoLand, PyCharm Pro, WebStorm, DataGrip, Fleet, Gateway
- [ ] Telepresence (work): https://telepresence.io/docs/install/client (not on winget or choco)
- [ ] Work dev environment setup guide
- [ ] Vimium + vimium-options.json
- [ ] Rsync for JetBrains remote run targets: install cygwin with openssh + rsync.
      In GoLand, set rsync and ssh to C:\cygwin64\bin\rsync.exe and C:\cygwin64\bin\ssh.exe.
      Add `db_home: windows` to C:\cygwin64\etc\nsswitch.conf so known_hosts works.

#>
