choco install zoom -y
choco install slack -y
choco install git -params '"/GitAndUnixToolsOnPath"' -y
choco install goland -y
choco install pycharm -y
choco install golang --version go1.17.10 -y
choco pin add --name=golang
choco install tortoisegit -y
choco install notepadplusplus -y
choco install 7zip.install -y
choco install postman -y
choco install rdcman -y
choco install keepass -y
choco install hxd -y
choco install kdiff3 -y
choco install mysql -y
choco install mysql.workbench -y
choco install putty -y
choco install windirstat -y
choco install winscp -y
choco install wireshark -y
choco install baretail -y
choco install autohotkey -y
choco install jq -y
choco install sysinternals -y
choco install sqlitebrowser -y
choco install sqlite.shell -y
choco install visualstudio2017professional -y
choco install poshgit -y
choco install openssl -y
choco install docker-desktop -y
choco install nimbletext -y
choco install vscode -y
choco install windbg -y
choco install adobereader -y
choco install k6 -y

choco install vim -y
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni $HOME/vimfiles/autoload/plug.vim -Force
vim +PlugInstall +qall

mkdir 'C:\Program Files\WinSW'
wget https://github.com/winsw/winsw/releases/download/v3.0.0-alpha.10/WinSW-x64.exe -OutFile 'C:\Program Files\WinSW\WinSW.exe'
[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + "C:\Program Files\WinSW;", [EnvironmentVariableTarget]::Machine)
$env:Path = $env:Path + "C:\Program Files\WinSW;"

## Rsync for Remote Run Targets in JetBrains
# Install cygwin using installer and selecting openssh + rsync packages.
# In Goland, select path to rsync and ssh: C:\cygwin64\bin\rsync.exe C:\cygwin64\bin\ssh.exe
# Have to edit C:\cygwin64\etc\nsswitch.conf and add `db_home: windows` to get known_hosts working

# Python2
choco install python2 --version 2.7.18 -x86 -y
choco pin add --name=python2
Set-Alias python2 C:\Python27\python.exe
pip2 install virtualenv==16.7.9
# Install vcpython27
# Install pywin32

# Python3
choco install python3 --version 3.6.8 -y
choco pin add --name=python3
start "https://aka.ms/vs/16/release/vs_buildtools.exe"  # Get latest SDK and latest compiler (14.x)
# Do this in cmd. Find correct location for the file:
# set CL=-FI"C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Tools\MSVC\14.29.30133\include\stdint.h"
# pip install pycrypto==2.6.1


#Entertainment
choco install spotify -y


# DBF/Office
choco install openoffice -y


# Non-Choco
if ((wsl) -ne $null )
{
    wsl --install
}

iwr https://github.com/jmeubank/tdm-gcc/releases/download/v1.2105.1/tdm-gcc-webdl.exe -OutFile C:\tmp\tdm-gcc-webdl.exe
& C:\tmp\tdm-gcc-webdl.exe




<#
Manual

- [ ] viscosity
- [ ] wsl --install
- [ ] Vimium + settings in dotfiles
- [ ] TGit Merge settings
- [ ] TDM GCC: https://jmeubank.github.io/tdm-gcc/articles/2021-05/10.3.0-release

#>
