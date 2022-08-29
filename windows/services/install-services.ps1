#TODO: Use Get-Credential to get once
#$c = Get-Credential "jlevitt"
#$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($c.Password)
#$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
#$UnsecurePassword

winsw install $PSScriptRoot\Omniprox\Omniprox.xml
gsv Omniprox | sasv

winsw install $PSScriptRoot\MySqlDevTunnel\MySqlDevTunnel.xml
gsv MySqlDevTunnel | sasv

winsw install $PSScriptRoot\MySqlDevCloudPOSTunnel\MySqlDevCloudPOSTunnel.xml
gsv MySqlDevCloudPOSTunnel | sasv

winsw install $PSScriptRoot\SFTPTunnel\SFTPTunnel.xml
gsv SFTPTunnel | sasv

winsw install $PSScriptRoot\RabbitMQAdminTunnel\RabbitMQAdminTunnel.xml
gsv RabbitMQAdminTunnel | sasv

