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

  xcodeapp="$3/Applications/Xcode.app"

    if [ -e "$xcodeapp" ]; then

       # "Xcode has been found, assuming this a developer image..."

       # "Installing Cisco AnyConnect Secure Mobility Client..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/vpn_module.pkg" -target $3

       # "Installing Cisco AnyConnect Secure Mobility DART Module..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/dart_module.pkg" -target $3

       # "Installing Bitdefender GravityZone Business Security..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/antivirus_for_mac.pkg" -target $3

      # "Installing Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/RFK/Software/CharlesProxy/charles-proxy-3.11.5.dmg" > /dev/null
      cp -R /Volumes/Charles\ Proxy\ v3.11.5/Charles.app "$3/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.5
      cp "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
      chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      chown $LoggedInUser:staff "$3/Applications/Charles.app"
      security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/RFK/Software/CharlesProxy/charlesproxy.cer" srm "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"

    else

       # "Xcode has not been found, assuming this is not a developer image..."

       # "Installing Cisco AnyConnect Secure Mobility Client..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/vpn_module.pkg" -target $3

       # "Installing Cisco AnyConnect Secure Mobility DART Module..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/dart_module.pkg" -target $3

       # "Install Microsoft Office 2016 15.23..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_Office_2016_15.23.0_160611_Installer.pkg" -target $3

       # "Installing Microsoft Delta Update for Excel 15.23.0 to 15.23.1..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_Excel_15.23.0_160611_to_15.23.1_160617_Delta.pkg" -target $3

       # "Installing Microsoft Delta Update for Word 15.23.0 to 15.23.1..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_Word_15.23.0_160611_to_15.23.1_160617_Delta.pkg" -target $3
      
       # "Installing Microsoft Delta Update for Excel 15.23.1 to 15.23.2..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_Excel_15.23.1_160617_to_15.23.2_160624_Delta.pkg" -target $3

       # "Installing Microsoft Delta Update for Word 15.23.1 to 15.23.2..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_Word_15.23.1_160617_to_15.23.2_160624_Delta.pkg" -target $3
      
       # "Installing Microsoft Delta Update for PowerPoint 15.23.0 to 15.23.2..."
      /usr/sbin/installer -pkg "/Library/RFK/JIDOKA/Microsoft_PowerPoint_15.23.0_160611_to_15.23.2_160624_Delta.pkg" -target $3

      # "Installing Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/RFK/Software/CharlesProxy/charles-proxy-3.11.5.dmg" > /dev/null
      cp -R /Volumes/Charles\ Proxy\ v3.11.5/Charles.app "$3/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.5
      cp "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
      chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      chown $LoggedInUser:staff "$3/Applications/Charles.app"
      security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/RFK/Software/CharlesProxy/charlesproxy.cer" srm "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"
      
      cisco="$3/Applications/Cisco/Cisco\ AnyConnect\ Secure\ Mobility\ Client.app"
      msexcel="$3/Applications/Microsoft\ Excel.app"
      charlesproxy="$3/Applications/Charles.app"
      
      if [ -e "$cisco" ]; then
      
      
    fi

exit 0		## Success
exit 1		## Failure
