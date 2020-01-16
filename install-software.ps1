Set-ExecutionPolicy Unrestricted
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install devbox-rapidee -y
choco install tortoisegit -y
choco install git -params '"/GitAndUnixToolsOnPath /NoAutoCrlf"' -y
choco install notepadplusplus -y
choco install 7zip.install -y
choco install conemu -y
choco install postman -y
choco install vim -y
choco install rdcman -y
choco install keepass -y
choco install lockhunter -y
choco install fiddler -y
choco install NuGet.CommandLine
choco install NugetPackageExplorer -y
choco install pandoc -y
choco install hxd -y
choco install kdiff3 -y
choco install haskellplatform -y
choco install virtualbox -y
choco install vagrant -y
choco install logparser -y
choco install mysql -y
choco install mysql.workbench -y
choco install shexview.portable -y
choco install putty -y
choco install windirstat -y
choco install winscp -y
choco install wireshark -y
choco install baretail -y
choco install autohotkey -y
choco install jq -y
choco install sysinternals -y
choco install nssm -y # Service Manager - https://nssm.cc
choco install sqlitebrowser -y


# Python

# Privacy
choco install gpg4win -y

# Finance
choco install kmymoney -y

# Has non choco dependencies
choco install resharper

# Non-choco
(new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

# Other
# * Posh git

