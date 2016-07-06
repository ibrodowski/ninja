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

 # "Installing Cisco AnyConnect Secure Mobility Client..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/vpn_module.pkg" -target $3

 # "Installing Cisco AnyConnect Secure Mobility DART Module..."
/usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/dart_module.pkg" -target $3

exit 0		## Success
exit 1		## Failure
