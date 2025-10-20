function Validate-Creds($cred)
{
    # Import the required .NET assembly
    Add-Type -AssemblyName System.DirectoryServices.AccountManagement

    # Define the context (local machine)
    # For domain, use: [System.DirectoryServices.AccountManagement.ContextType]::Domain
    $contextType = [System.DirectoryServices.AccountManagement.ContextType]::Machine

    # Create the principal context
    $context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext($contextType)

    # Use the ValidateCredentials method
    $context.ValidateCredentials($cred.UserName, $cred.GetNetworkCredential().Password)
}


$c = Get-Credential

$isValid = $false
try
{
    Write-Host "Validating credentials..." -ForegroundColor Cyan
    $isValid = Validate-Creds $c
    if ($isValid) {
        Write-Host "Credentials are valid." -ForegroundColor Green
    } else {
        Write-Host "Credentials are NOT valid (e.g., invalid username or password)." -ForegroundColor Red
    }
}
catch
{
    # This will catch other errors, like the user not existing
    Write-Warning "An error occurred during validation: $($_.Exception.Message)"
}

if (-not $isValid)
{
    exit
}

winsw install $PSScriptRoot\Omniprox\Omniprox.xml --user $c.GetNetworkCredential().Username --password $c.GetNetworkCredential().Password
gsv Omniprox | sasv

winsw install $PSScriptRoot\MySqlDevTunnel\MySqlDevTunnel.xml --user $c.GetNetworkCredential().Username --password $c.GetNetworkCredential().Password
gsv MySqlDevTunnel | sasv

winsw install $PSScriptRoot\SFTPTunnel\SFTPTunnel.xml --user $c.GetNetworkCredential().Username --password $c.GetNetworkCredential().Password
gsv SFTPTunnel | sasv

winsw install $PSScriptRoot\RabbitMQAdminTunnel\RabbitMQAdminTunnel.xml --user $c.GetNetworkCredential().Username --password $c.GetNetworkCredential().Password
gsv RabbitMQAdminTunnel | sasv

winsw install $PSScriptRoot\DashDevTunnel\DashDevTunnel.xml --user $c.GetNetworkCredential().Username --password $c.GetNetworkCredential().Password
gsv DashDevTunnel | sasv

