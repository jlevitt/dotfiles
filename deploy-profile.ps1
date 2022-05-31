$deployParamsPath = ".deploy-profile-params.xml"
$profileParams = @{}
$expectedParams = @(
    'HOME_DIR',
    'USE_POSH_GIT',
    'PROJECTS_DIR',
    'EDITOR',
    'VM_TYPE',
    'ZOOM_ROOM_PASSWORD',
    'GITHUB_SSH_KEY'
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
