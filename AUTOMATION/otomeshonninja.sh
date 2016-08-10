#!/bin/bash
set -x
## postinstall
#
#
# Author          : Ian Brodowski
# Latest Update   : Wednesday, August 10, 2016
# 
# Purpose         : Install third-party software that is not otherwise integrated within the RFK developer or standard image(s)
#
# Change History  :
#   * 20160810    : Added initial UI/UX test code for CocoaDialog input and output capture for script use
#                 : Added Terminal dock icon for Developer image
#                 : Commented out 'OS_Version' because it is not called within this script
#                 : Removed all prefixes of $3 in front of any root-residing directories (i.e., it gives the explicit path an extra forward slash)
#                 : Separated 'security' command from 'srm' when installing the Charles Proxy certificate
#
#   * 20160809    : Added the CocoaDialog utility for future enhancements /Library/RFK/Software/bin/utils/CocoaDialog.app
#                 : Modified method for setting Finder Preferences to Show hard disks on the Desktop
#                 :   Since the AppleScript returns the value of 'true', it's best to redirect it to /dev/null
#
#   * 20160808    : Added method to add and remove dock icons
#                 : Added method to set Desktop Picture to ReflektionInc.png
#                 : Added method to set Finder Preferences to Show hard disks on the Desktop
#                 : Added method to recoup drive space after the installation of Microsoft Office 2016 15.24
#                 : Changed paths from /Library/RFK/JIDOKA to /Library/RFK/Software
#
#   * 20160803    : Added method to determine if script installed application exists and if so exit 0, else exit 1
#
#   * 20160801    : Updated postintall script for new release of Microsoft Office 2016 15.24 - 20160709
#                 :   The lines that have been commented out are for reference purposes, should additional updates be released
#
pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

#OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
  if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
      LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
  fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
cocoadialog=/Library/RFK/Software/bin/utils/CocoaDialog.app/Contents/MacOS/CocoaDialog
dockutil=/Library/RFK/Software/bin/utils/dockutil
scripts=/Library/RFK/Software/bin/scpt

  xcodeapp="/Applications/Xcode.app"

    if [ -e "$xcodeapp" ]; then

       # "Xcode has been found, assuming this a developer image..."

       # "Installing Cisco AnyConnect Secure Mobility Client..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/vpn_module.pkg" -target $3

       # "Installing Cisco AnyConnect Secure Mobility DART Module..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/dart_module.pkg" -target $3

       # "Installing Bitdefender GravityZone Business Security..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Bitdefender/antivirus_for_mac.pkg" -target $3

      # "Installing Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/RFK/Software/CharlesProxy/charles-proxy-3.11.5.dmg" > /dev/null
      /bin/cp -R /Volumes/Charles\ Proxy\ v3.11.5/Charles.app "/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.5
      /bin/cp "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
      /usr/bin/srm "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config"
      /usr/sbin/chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      /usr/sbin/chown $LoggedInUser:staff "/Applications/Charles.app"
      /usr/bin/security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"
      /usr/bin/srm "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"

      # Set Desktop Picture to ReflektionInc.png
      /usr/bin/osascript "$scripts"/setdesktoppic.scpt

      # Set Finder Preferences to Show Hard disks on the Desktop
      /usr/bin/osascript "$scripts"/setfinderprefs.scpt > /dev/null

      # "Add/Remove dock icons"
      # Remove miscellaneous dock icons
      "$dockutil" --remove 'iBooks' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'iTunes' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'Maps' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'Photos' --no-restart
      sleep 2 # sleep for two seconds

      # Add third-party web browsers to dock
      "$dockutil" --add '/Applications/Google Chrome.app' --after 'Safari' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --add '/Applications/Firefox.app' --after 'Google Chrome' --no-restart
      sleep 2 # sleep for two seconds

      # Add Slack to dock
      "$dockutil" --add '/Applications/Slack.app' --before 'Mail' --no-restart
      sleep 2 # sleep for two seconds

      # Add Terminal to dock
      "$dockutil" --add '/Applications/Utilities/Terminal.app' --after 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds

      # Add Charles Proxy to dock
      "$dockutil" --add '/Applications/Charles.app' --after 'Terminal' --no-restart
      sleep 2 # sleep for two seconds
          
      # Add Cisco AnyConnect Secure Mobility Client to dock
      "$dockutil" --add '/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app' --after 'Charles'

      # Interactive user input for script processing (in testing...)
      #ben=`$cocoadialog standard-inputbox --title "Information Required" --informative-text "Please enter your email address:"`
      #button=`echo "${ben}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #StandardInputbox_Output=`echo "${ben}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$StandardInputbox_Output" --icon "info" --timeout "15"

      declare -xa APPS=('Charles.app' \
                        'Cisco/Cisco AnyConnect Secure Mobility Client.app' )

      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")

      for app in ${APPS[@]}; do
        if [[ -d /Applications/"$app" ]]; then
          exit 0
        else
          exit 1
        fi
      done

      IFS=$SAVEIFS

    else

       # "Xcode has not been found, assuming this is not a developer image..."

       # "Installing Cisco AnyConnect Secure Mobility Client..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/vpn_module.pkg" -target $3

       # "Installing Cisco AnyConnect Secure Mobility DART Module..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Cisco/dart_module.pkg" -target $3

       # "Install Microsoft Office 2016 15.24..."
      /usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft/Microsoft_Office_2016_15.24.0_160709_Installer.pkg" -target $3

      # Recoup drive space by deleting /Library/RFK/Software/Microsoft/Microsoft_Office_2016_15.24.0_160709_Installer.pkg
      /usr/bin/srm -s "/Library/RFK/Software/Microsoft/Microsoft_Office_2016_15.24.0_160709_Installer.pkg"

       # "Installing Microsoft Delta Update for Excel 15.23.0 to 15.23.1..."
      #/usr/sbin/installer -pkg "/Library/RFK/Software/Microsoft_Excel_15.23.0_160611_to_15.23.1_160617_Delta.pkg" -target $3

      # "Installing Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/RFK/Software/CharlesProxy/charles-proxy-3.11.5.dmg" > /dev/null
      /bin/cp -R /Volumes/Charles\ Proxy\ v3.11.5/Charles.app "/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.5
      /bin/cp "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
      /usr/bin/srm "/Library/RFK/Software/CharlesProxy/com.xk72.charles.config"
      /usr/sbin/chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      /usr/sbin/chown $LoggedInUser:staff "/Applications/Charles.app"
      /usr/bin/security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"
      /usr/bin/srm "/Library/RFK/Software/CharlesProxy/charlesproxy.cer"

      # Set Desktop Picture to ReflektionInc.png
      /usr/bin/osascript "$scripts"/setdesktoppic.scpt

      # Set Finder Preferences to Show Hard disks on the Desktop
      /usr/bin/osascript "$scripts"/setfinderprefs.scpt > /dev/null

      # "Add applications to dock"
      # Remove miscellaneous dock icons
      "$dockutil" --remove 'iBooks' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'iTunes' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'Maps' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --remove 'Photos' --no-restart
      sleep 2 # sleep for two seconds

      # Add third-party web browsers to dock
      "$dockutil" --add '/Applications/Google Chrome.app' --after 'Safari' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --add '/Applications/Firefox.app' --after 'Google Chrome' --no-restart
      sleep 2 # sleep for two seconds

      # Add Slack to dock
      "$dockutil" --add '/Applications/Slack.app' --before 'Mail' --no-restart
      sleep 2 # sleep for two seconds

      # Add Microsoft Office Suite to dock, with the exception of OneNote
      "$dockutil" --add '/Applications/Microsoft Excel.app' --before 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --add '/Applications/Microsoft Outlook.app' --before 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --add '/Applications/Microsoft PowerPoint.app' --before 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds
      "$dockutil" --add '/Applications/Microsoft Word.app' --before 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds

      # Add Charles Proxy to dock
      "$dockutil" --add '/Applications/Charles.app' --after 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds
          
      # Add Cisco AnyConnect Secure Mobility Client to dock and restart dock
      "$dockutil" --add '/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app' --after 'Charles'

      # Interactive user input for script processing (in testing...)
      #ben=`$cocoadialog standard-inputbox --title "Information Required" --informative-text "Please enter your email address:"`
      #button=`echo "${ben}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #StandardInputbox_Output=`echo "${ben}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$StandardInputbox_Output" --icon "info" --timeout "15"

      declare -xa APPS=('Charles.app' \
                        'Cisco/Cisco AnyConnect Secure Mobility Client.app' \
                        'Microsoft Excel.app' \
                        'Microsoft Outlook.app' \
                        'Microsoft PowerPoint.app' \
                        'Microsoft Word.app' )

      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")

      for app in ${APPS[@]}; do
        if [[ -d /Applications/"$app" ]]; then
          exit 0
        else
          exit 1
        fi
      done

      IFS=$SAVEIFS

    fi
