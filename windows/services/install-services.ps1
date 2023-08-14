winsw install $PSScriptRoot\Omniprox\Omniprox.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv Omniprox | sasv

winsw install $PSScriptRoot\MySqlDevTunnel\MySqlDevTunnel.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv MySqlDevTunnel | sasv

winsw install $PSScriptRoot\MySqlDevTunnel-Focal\MySqlDevTunnel-Focal.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv MySqlDevTunnelFocal | sasv

winsw install $PSScriptRoot\MySqlDevCloudPOSTunnel\MySqlDevCloudPOSTunnel.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv MySqlDevCloudPOSTunnel | sasv

winsw install $PSScriptRoot\SFTPTunnel\SFTPTunnel.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv SFTPTunnel | sasv

winsw install $PSScriptRoot\SFTPTunnel-Focal\SFTPTunnel-Focal.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv SFTPTunnelFocal | sasv

winsw install $PSScriptRoot\RabbitMQAdminTunnel\RabbitMQAdminTunnel.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv RabbitMQAdminTunnel | sasv

winsw install $PSScriptRoot\DashDevTunnel\DashDevTunnel.xml --user $env:WINSW_USERNAME --password $env:WINSW_PASSWORD
gsv DashDevTunnel | sasv

