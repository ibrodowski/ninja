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

  # "Installing Charles Proxy..."
  yes | /usr/bin/hdiutil attach -nobrowse "/Library/RFK/Software/CharlesProxy/charles-proxy-3.11.5.dmg" > /dev/null
  cp -R /Volumes/Charles\ Proxy\ v3.11.5/Charles.app "$3/Applications/"
  /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.5
  cp "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
  chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
  security add-trusted-cert -d -r trustRoot -k "/Library/Keychains/System.keychain" "$3/Library/RFK/Software/CharlesProxy/charlesproxy.cer" srm "$3/Library/RFK/Software/CharlesProxy/charlesproxy.cer"

  charlesproxyapp="$3/Applications/Charles.app"
  charlesproxypref="$HOMEDIR"/Library/Preferences/com.xk72.charles.config

  if [ -e "$charlesproxyapp" ]; then
    if [ -e "$charlesproxypref" ]; then
      exit 0    ## Success
    fi
  else
    exit 1    ## Failure
  fi
