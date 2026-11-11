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
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System ConsentPromptBehaviorAdmin 0  # UAC: never notify
Set-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System PromptOnSecureDesktop 0
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
    winget import "$PSScriptRoot\packages\$list.json" --accept-package-agreements --accept-source-agreements --ignore-unavailable --no-upgrade
}

# Postman 12 isn't supported yet; the pin keeps winget upgrade --all on 11.x.
winget install --id Postman.Postman -e --version 11.86.1 --no-upgrade --accept-package-agreements
winget pin add --id Postman.Postman --version '11.*'

# Machine scope so the installer drops gvim.bat/vim.bat into C:\Windows; the per-user install leaves vim off PATH.
winget install --id vim.vim -e --scope machine --no-upgrade --accept-package-agreements

if ($Work)
{
    winget install --id Microsoft.VisualStudio.Professional -e --no-upgrade --accept-package-agreements --override '--wait --quiet --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack'
    # 32-bit 3.13 alongside the default 3.14 from both.json.
    winget install --id Python.Python.3.13 -e --architecture x86 --no-upgrade --accept-package-agreements
}

# Cascadia Code NF for Windows Terminal. Microsoft's own Nerd Font build is only in the GitHub release zip.
$cascadiaVersion = '2407.24'
$cascadiaZip = "$env:TEMP\CascadiaCode-$cascadiaVersion.zip"
$ProgressPreference = 'SilentlyContinue'  # Invoke-WebRequest is much slower with the progress bar
Invoke-WebRequest "https://github.com/microsoft/cascadia-code/releases/download/v$cascadiaVersion/CascadiaCode-$cascadiaVersion.zip" -OutFile $cascadiaZip
$ProgressPreference = 'Continue'
Expand-Archive $cascadiaZip "$env:TEMP\CascadiaCode-$cascadiaVersion" -Force
foreach ($font in @{ 'CascadiaCodeNF.ttf' = 'Cascadia Code NF'; 'CascadiaCodeNFItalic.ttf' = 'Cascadia Code NF Italic' }.GetEnumerator())
{
    Copy-Item "$env:TEMP\CascadiaCode-$cascadiaVersion\ttf\$($font.Key)" "$env:WINDIR\Fonts" -Force
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' "$($font.Value) (TrueType)" $font.Key
}

# Chocolatey, for what winget doesn't have
if (-not (Get-Command choco -ErrorAction SilentlyContinue))
{
    Invoke-RestMethod https://community.chocolatey.org/install.ps1 | Invoke-Expression
}
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
    # Enabling re-runs servicing even when already on, so only pass features that are off.
    $features = 'IIS-WebServerRole', 'IIS-ManagementConsole', 'IIS-ASPNET45', 'TelnetClient' | Where-Object { (Get-WindowsOptionalFeature -Online -FeatureName $_).State -ne 'Enabled' }
    if ($features)
    {
        Enable-WindowsOptionalFeature -Online -All -NoRestart -FeatureName $features | Out-Null
    }

    # -Force skips the untrusted-repository and NuGet prompts, but also reinstalls, so only pass modules that are missing.
    $modules = 'Az', 'AWS.Tools.Installer', 'PsIni', 'DotNetVersionLister' | Where-Object { -not (Get-Module $_ -ListAvailable) }
    if ($modules)
    {
        Install-Module $modules -Scope CurrentUser -Force -Repository PSGallery
    }

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
    # Internal tool with no download location, so it can't live in this public repo.
    if (-not (Test-Path "$env:ProgramFiles\omniprox\omniprox.exe"))
    {
        Write-Host "Manual step: copy omniprox.exe from your old machine to $env:ProgramFiles\omniprox\omniprox.exe (the Omniprox service runs it from there)." -ForegroundColor Yellow
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
- [ ] Settings > Personalization > Taskbar > Widgets off (UCPD blocks scripted registry writes for this)
- [ ] Spotify, from a non-admin shell (its installer refuses to run elevated): winget install -e --id Spotify.Spotify
- [ ] Work dev environment setup guide
- [ ] Vimium + vimium-options.json
- [ ] Rsync for JetBrains remote run targets: install cygwin with openssh + rsync.
      In GoLand, set rsync and ssh to C:\cygwin64\bin\rsync.exe and C:\cygwin64\bin\ssh.exe.
      Add `db_home: windows` to C:\cygwin64\etc\nsswitch.conf so known_hosts works.

#>
