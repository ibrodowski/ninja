#!/bin/bash
#
# Author	  : Ian Brodowski
# Last Update     : Sunday, June 19, 2016
#
# Change History  :
#   * 20160619    : Removed Bitdefender for Standard image
#
#   * 20160618    : Added MS Excel and MS Word Delta Updates
#
#   * 20160617    : Initial release
#
#
#
# Define Global Variables
OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
  if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
      LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
  fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
CURRENTDIR=`pwd`

main () {

  xcodeapp="/Applications/Xcode.app"
    if [ -e "$xcodeapp" ]; then

      echo "Xcode has been found, assuming this a developer image..."

      echo "Installing Cisco AnyConnect Secure Mobility Client..."
      installer -pkg "$CURRENTDIR"/vpn_module.pkg -target /

      echo "Installing Cisco AnyConnect Secure Mobility DART Module..."
      installer -pkg "$CURRENTDIR"/dart_module.pkg -target /

      echo "Installing Bitdefender GravityZone Business Security..."
      installer -pkg "$CURRENTDIR"/antivirus_for_mac.pkg -target /

      echo "Installing Charles Proxy..."
      #hdiutil mount "$CURRENTDIR"/Charles.dmg
      #cp -R "/Volumes/Charles/Charles.app" /Applications
      #hdiutil unmount "/Volumes/Charles"
      cp "$CURRENTDIR"/com.xk72.charles.config "$HOMEDIR"/Library/Preferences

    else

      echo "Xcode has not been found, assuming this is not a developer image..."

      echo "Installing Cisco AnyConnect Secure Mobility Client..."
      installer -pkg "$CURRENTDIR"/vpn_module.pkg -target /

      echo "Installing Cisco AnyConnect Secure Mobility DART Module..."
      installer -pkg "$CURRENTDIR"/dart_module.pkg -target /

      echo "Install Microsoft Office 2016 15.23..."
      installer -pkg "$CURRENTDIR"/Microsoft_Office_2016_15.23.0_160611_Installer.pkg -target /

      echo "Installing Microsoft Delta Update for Excel 15.23.0 to 15.23.1..."
      installer -pkg "$CURRENTDIR"/Microsoft_Excel_15.23.0_160611_to_15.23.1_160617_Delta.pkg -target /

      echo "Installing Microsoft Delta Update for Word 15.23.0 to 15.23.1..."
      installer -pkg "$CURRENTDIR"/Microsoft_Word_15.23.0_160611_to_15.23.1_160617_Delta.pkg -target /

      #echo "Installing Bitdefender GravityZone Business Security..."
      #installer -pkg "$CURRENTDIR"/antivirus_for_mac.pkg -target /
      
      #echo "Installing Charles Proxy..."
      #hdiutil mount "$CURRENTDIR"/Charles.dmg
      #cp -R "/Volumes/Charles/Charles.app" /Applications
      #hdiutil unmount "/Volumes/Charles"
      cp "$CURRENTDIR"/com.xk72.charles.config "$HOMEDIR"/Library/Preferences

    fi

  exit

}

if [ $UID != 0 ]; then
  echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == "10.11.5" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   main
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   exit 2
fi
