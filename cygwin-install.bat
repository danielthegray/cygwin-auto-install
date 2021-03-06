@ECHO OFF
REM -- Automates cygwin installation
REM -- Source: https://github.com/rtwolf/cygwin-auto-install
REM -- Based on: https://gist.github.com/wjrogers/1016065
 
SETLOCAL
 
REM -- Change to the directory of the executing batch file
CD %~dp0

REM -- Download the Cygwin installer
IF NOT EXIST cygwin-setup.exe (
	ECHO cygwin-setup.exe NOT found! Downloading installer...
	bitsadmin /transfer cygwinDownloadJob /download /priority normal https://cygwin.com/setup-x86_64.exe %CD%\\cygwin-setup.exe
) ELSE (
	ECHO cygwin-setup.exe found! Skipping installer download...
)
 
REM -- Configure our paths
SET SITE=http://cygwin.mirrors.pair.com/
SET LOCALDIR=C:/cygwin64/packages
SET ROOTDIR=C:/cygwin64
 
REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,git-svn,stgit,openssh,bash-completion,curl,make
REM -- These are necessary for apt-cyg install, do not change. Any duplicates will be ignored.
SET PACKAGES=%PACKAGES%,wget,tar,gawk,bzip2,subversion,unzip,xz
REM -- Add programming languages
SET PACKAGES=%PACKAGES%,python37,python37-pip,perl-libwww-perl,perl-Net-SSLeay,perl-YAML,perl-JSON
REM -- More generic utils
SET PACKAGES=%PACKAGES%,tree,jq,graphviz,autossh,vim,tmux,dos2unix,expect,moreutils
 
REM -- More info on command line options at: https://cygwin.com/faq/faq.html#faq.setup.cli
REM -- Do it!
ECHO *** Installing default packages
cygwin-setup --wait --quiet-mode --no-desktop --download --local-install --site %SITE% --local-package-dir "%LOCALDIR%" --root "%ROOTDIR%"
ECHO.
ECHO.
ECHO *** Installing custom packages
cygwin-setup --wait --quiet-mode --no-desktop --download --local-install --site %SITE% --local-package-dir "%LOCALDIR%" --root "%ROOTDIR%" --packages %PACKAGES%
 
REM -- Show what we did
ECHO.
ECHO.
ECHO cygwin installation updated
ECHO  - %PACKAGES%
ECHO.

set PATH=%ROOTDIR%/bin;%PATH%
ECHO *** Installing apt-cyg
%ROOTDIR%/bin/bash.exe -c "wget rawgit.com/transcode-open/apt-cyg/master/apt-cyg && install apt-cyg /bin"
ECHO *** Making the C: drive accessible via /c/ instead of /cygdrive/c/
%ROOTDIR%/bin/bash.exe -c "sed -i.orig -e 's/\/cygdrive cygdrive/\/ cygdrive/' /etc/fstab"
ECHO *** Installing the AWS cli via pip
%ROOTDIR%/bin/bash.exe -c "pip3.7 install awscli --upgrade --user"
ECHO *** Set up home folder symlinks
IF NOT EXIST "%ROOTDIR%\home\%USERNAME%" (
	mkdir "%ROOTDIR%\home\%USERNAME%"
)
IF NOT EXIST "%USERPROFILE%\.gradle" (
	mkdir "%USERPROFILE%\.gradle"
)
IF NOT EXIST "%ROOTDIR%\home\%USERNAME%\.gradle" (
	mklink /j "%ROOTDIR%\home\%USERNAME%\.gradle" "%USERPROFILE%\.gradle"
)
IF NOT EXIST "%USERPROFILE%\.aws" (
	mkdir "%USERPROFILE%\.aws"
)
IF NOT EXIST "%ROOTDIR%\home\%USERNAME%\.aws" (
	mklink /j "%ROOTDIR%\home\%USERNAME%\.aws" "%USERPROFILE%\.aws"
)
IF NOT EXIST "%USERPROFILE%\.ssh" (
	mkdir "%USERPROFILE%\.ssh"
)
IF NOT EXIST "%ROOTDIR%\home\%USERNAME%\.ssh" (
	mklink /j "%ROOTDIR%\home\%USERNAME%\.ssh" "%USERPROFILE%\.ssh"
)

ENDLOCAL
 
PAUSE
EXIT /B 0
