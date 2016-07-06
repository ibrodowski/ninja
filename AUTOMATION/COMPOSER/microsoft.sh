#!/bin/sh
## postinstall

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
  if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
      LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
  fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')

 # "Install Microsoft Office 2016 15.23..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Office_2016_15.23.0_160611_Installer.pkg" -target $3

 # "Installing Microsoft Delta Update for Excel 15.23.0 to 15.23.1..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Excel_15.23.0_160611_to_15.23.1_160617_Delta.pkg" -target $3

 # "Installing Microsoft Delta Update for Word 15.23.0 to 15.23.1..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Word_15.23.0_160611_to_15.23.1_160617_Delta.pkg" -target $3
      
 # "Installing Microsoft Delta Update for Excel 15.23.1 to 15.23.2..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Excel_15.23.1_160617_to_15.23.2_160624_Delta.pkg" -target $3

 # "Installing Microsoft Delta Update for Word 15.23.1 to 15.23.2..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Word_15.23.1_160617_to_15.23.2_160624_Delta.pkg" -target $3
      
 # "Installing Microsoft Delta Update for PowerPoint 15.23.0 to 15.23.2..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_PowerPoint_15.23.0_160611_to_15.23.2_160624_Delta.pkg" -target $3

exit 0		## Success
exit 1		## Failure
