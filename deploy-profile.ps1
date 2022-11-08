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

Get-Content .\Microsoft.PowerShell_profile.ps1 | Merge-Tokens -tokens $profileParams | Set-Content $PROFILE
Write-Host "Profile written [OK]"

Get-Content .\.gitconfig-template | Merge-Tokens -tokens $profileParams | Set-Content ~\.gitconfig
Get-Content .\.gitconfig-template | Merge-Tokens -tokens $profileParams | Set-Content \\wsl$\Ubuntu-20.04\home\jlevitt\.gitconfig
Write-Host "Git config written [OK]"

if ($profileParams["USE_POSH_GIT"] -and -not (Get-Module posh-git))
{
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
    Write-Host "PoshGit module installed [OK]"
}

$installAgentModulePath = "C:\Program Files\WindowsPowerShell\Modules\InstallAgent"
if (-not $(Test-Path $installAgentModulePath))
{
    mkdir $installAgentModulePath | Out-Null
}
cp .\InstallAgent.psm1 $installAgentModulePath\InstallAgent.psm1
Write-Host "InstallAgent module written [OK]"

cp $dotfiles\windows\laptop\.vimlayout $homeDir\.vimlayout -Force
Write-Host ".vimlayout written [OK]"

reg import $dotfiles\TortoiseGit.reg | Out-Null
reg import $dotfiles\TortoiseGitMerge.reg | Out-Null
Write-Host "TortoiseGit settings installed to registry [OK]"

$windowsTerminalPath = "~\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $windowsTerminalPath)
{
    cp $dotfiles\windows\terminal\settings.json $windowsTerminalPath
    Write-Host "Windows Terminal settings.json written [OK]"
}

$windowsTerminalPreviewPath = "~\AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
if (Test-Path $windowsTerminalPreviewPath)
{
    cp $dotfiles\windows\terminal\settings-preview.json $windowsTerminalPreviewPath
    Write-Host "Windows Terminal Preview settings.json written [OK]"
}

cp $dotfiles\wsl\.wslconfig $homeDir\.wslconfig
Write-Host ".wslconfig written [OK]"

cp $dotfiles\windows\laptop\.bashrc $homeDir\.bashrc
Write-Host "Windows .bashrc written [OK]"

gci $dotfiles\wsl -Exclude .gitattributes | cp -Destination \\wsl$\Ubuntu-20.04\home\jlevitt
Write-Host "WSL dotfiles written [OK]"

$gopath = "$projects\go"
[Environment]::SetEnvironmentVariable('GOPATH', $gopath, [EnvironmentVariableTarget]::Machine)
$env:GOPATH = $gopath
Write-Host "GOPATH written ($gopath) [OK]"

