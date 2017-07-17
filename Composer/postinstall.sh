#!/bin/bash
set -x
## postinstall
#
#
# Author          : Ian Brodowski
# Latest Update   : Monday, July 17, 2017
# 
# Purpose         : Install third-party software that is not otherwise integrated within the "Company Name" developer or standard image(s)
#
# Change History  :
#   * 20170707    : Debugging;
#				  :	Find and Replace All "Company Name" with the Company's Name (without quotes)
#				  :	Find and Replace All "Company Location" with the Company's Location (without quotes)
#				  :	Find and Replace All "adminaccount" with administrative account name (without quotes)
#
#   * 20161219    : Debugging;
#                 : Found an issue with the /opt folder showing up after the installation of the Cisco AnyConnect Secure Mobility Client v3.x
#                 : Found an issue with adding Visual Studio Code to the dock using dockutil; incorrect path given.
#
#   * 20161128    : Debugging;
#                 : Found an issue with the /opt folder showing up after the installation of the Cisco AnyConnect Secure Mobility Client v3.x
#                 : Found an issue with adding Visual Studio Code to the dock using dockutil; incorrect path given.
#
#   * 20161123    : Debugging;
#                 : Removed Cisco AnyConnect Secure Mobility Client and Diagnostics and Reporting Tool from Standard image
#                 : Updated GlobalProtect VPN Client v3.1.3-21 to v3.1.4-7 (No longer installed by Default for Standard image, but is available for installation)
#                 : Updated Microsoft Office 2016 15.27 to 15.28
#
#   * 20161109    : Debugging;
#                 : Added Lexmark Printer Drivers v3.1 for "Company Location" Office
#                 : Added new Lexmark CX410DE MFP "Company Location" Printer
#                 : Added Palo Alto Network's GlobalProtect VPN Client, Version 3.1.3-21
#                 : Updated Microsoft Office 2016 15.26 to 15.27
#
#   * 20161017    : Debugging;
#
#   * 20161016    : Debugging;
#                 : Updated to support macOS Sierra 10.12 (removed all references to srm, due to its removal)
#
#   * 20161006    : Debugging;
#                 : Added recursive permission repair for applications that are installed via AutoDMG
#
#   * 20160926    : Debugging
#
#   * 20160923    : Debugging
#                 : Added interactive feature to ask technician whether or not to install "Company Location" network printers
#
#   * 20160922    : Debugging;
#                 :   Found and corrected a pathing issue for Microsoft_Outlook_15.26.1_160916_Updater.pkg
#
#   * 20160916    : Updated Charles Proxy from v3.11.5 to v3.11.6
#                 : Updated Microsoft Office 2016 from 15.25 to 15.26
#                 : Includes Microsoft Outlook Update from 15.26.0 to 15.26.1
#
#   * 20160913    : Disabled installation of Bitdefender due to insufficient licensing
#
#   * 20160907    : Added 'sudo -H -u' $LoggedInUser for `lpoptions -d` and `defauts write org.cups.PrintingPrefs UseLastPrinter -bool False`
#                 : Updated Microsoft Office 2016 15.24 to 15.25.0 with a delta update for Excel from 15.25.0 to 15.25.1
#
#   * 20160818    : Modified chown to include -R for Charles.app
#
#   * 20160815    : Corrected grammatical errors
#                 : Added HP Printer Drivers
#                 : Added lpadmin commands to install HP Printers from within the "Company Location" HQ office
#                 : Added defaults and lpoption commands to disable last used printer and set the default printer to HP_LaserJet_200_Color_MFP_276nw
#                 : Added dock icons for IntelliJ IDEA CE, PyCharm CE and Robomongo for developer image
#
#   * 20160812    : Refined comments and notes for each section of the script
#                 : Added ability to enable Remote Management Features using kickstart from ARDAgent.app
#
#   * 20160811    : Added ability to set computer name based IATA airport code and user's name (i.e., prompt's user for information)
#                 : Added ability to enable Remote Management Features using kickstart from ARDAgent.app
#                 : Added additional UI/UX test code for CocoaDialog for password handling and obfuscation during entry
#                 : Added Terminal dock icon for Developer image
#
#   * 20160810    : Added initial UI/UX test code for CocoaDialog input and output capture for script use
#                 : Added Terminal dock icon for Developer image
#                 : Commented out 'OS_Version' because it is not called within this script
#                 : Removed all prefixes of $3 in front of any root-residing directories (i.e., it gives the explicit path an extra forward slash)
#                 : Separated 'security' command from 'srm' when installing the Charles Proxy certificate
#
#   * 20160809    : Added the CocoaDialog utility for future enhancements /Library/"Company Name"/Software/bin/utils/CocoaDialog.app
#                 : Modified method for setting Finder Preferences to Show hard disks on the Desktop
#                 :   Since the AppleScript returns the value of 'true', it's best to redirect it to /dev/null
#
#   * 20160808    : Added method to add and remove dock icons
#                 : Added method to set Desktop Picture to ReflektionInc.png
#                 : Added method to set Finder Preferences to Show hard disks on the Desktop
#                 : Added method to recoup drive space after the installation of Microsoft Office 2016 15.24
#                 : Changed paths from /Library/"Company Name"/JIDOKA to /Library/"Company Name"/Software
#
#   * 20160803    : Added method to determine if script installed application exists and if so exit 0, else exit 1
#
#   * 20160801    : Updated postintall script for new release of Microsoft Office 2016 15.24 - 20160709
#                 :   The lines that have been commented out are for reference purposes, should additional updates be released
#

#
# Define Variables
#

pathToScript=$0
pathToPackage=$1
targetLocation=$2
targetVolume=$3

#OS_Version=$(sw_vers -productVersion)
LoggedInUser=$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')
  if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
      LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
  fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
UserInLogged=$(echo "$LoggedInUser" | tr [a-z] [A-Z])
OS_Version=$(sw_vers -productVersion)
ardkick=/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart
cocoadialog=/Library/"Company Name"/Software/bin/utils/CocoaDialog.app/Contents/MacOS/CocoaDialog
dockutil=/Library/"Company Name"/Software/bin/utils/dockutil
scripts=/Library/"Company Name"/Software/bin/scpt


  #
  # Set 'xcodeapp' as variable to determine if '/Applications/Xcode.app' exists
  #
  xcodeapp="/Applications/Xcode.app"

    #
    # This section is intended for the developer image; i.e., non-standard deployment, as it does not install Microsoft Office 2016 x64 Edition
    #
    if [ -e "$xcodeapp" ]; then

      # "Xcode has been found, assuming this computer is running a corporate developer image..."

      #
      # If '/Applications/Xcode.app' exists then, install the following software:
      #   • Apple HP Printer Drivers v5.0
      #   • Apple Lexmark Printer Drivers v3.1
      #   • Charles Proxy 3.11.6
      #   • Cisco AnyConnect Secure Mobility Client (vpn_module.pkg)
      #   • Cisco AnyConnect Secure Mobility Client Diagnostics and Reporting Tool (dart_module.pkg)
      #   • Google Hangouts Plugin
      #   • Palo Alto Networks' GlobalProtect VPN Client, Version 3.1.4-7
      #

      # "Install Cisco AnyConnect Secure Mobility Client..."
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Cisco/vpn_module.pkg" -target $3

      # "Install Cisco AnyConnect Secure Mobility DART Module..."
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Cisco/dart_module.pkg" -target $3

      # "Hide /opt/ folder from Finder after installing Cisco AnyConnect Secure Mobility Client"
      /usr/bin/chflags hidden /opt

      # "Install Palo Alto Networks' GlobalProtect VPN Client..."
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/PAN/globalprotect.pkg" -target $3

      # "Install HP Printer Drivers"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/HP/HewlettPackardPrinterDrivers.pkg" -target $3

      # "Install Lexmark Printer Drivers"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Lexmark/LexmarkPrinterDrivers.pkg" -target $3

      # "Install Google Hangouts Plugin"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Google/Google\ Voice\ and\ Video.pkg" -target $3

      # Interactive user input to determine whether or not to install "Company Location" network printers
      officeprinters=`$cocoadialog yesno-msgbox --no-cancel --string-output --title "Printer Setup" --text "Install and configure "Company Location" network printers?"`

      if [[ "$officeprinters" == "Yes" ]]; then

        # "Install Lexmark CX410DE MFP 01"
        /usr/sbin/lpadmin -p "Lexmark_CX410DE_MFP01" -E -v "lpd://10.7.10.186" -P /Library/Printers/PPDs/Contents/Resources/Lexmark\ CX410\ Series.gz -D "Lexmark CX410DE MFP01" -L ""Company Location" HQ" -o printer-is-shared=false  

        # "Install HP LaserJet 200 Color MFP 276nw"
        /usr/sbin/lpadmin -p "HP_LaserJet_200_Color_MFP_276nw" -E -v "lpd://10.7.10.45" -P /Library/Printers/PPDs/Contents/Resources/HP\ LaserJet\ 200\ color\ MFP\ M276.gz -D "HP LaserJet 200 Color MFP M276nw" -L ""Company Location" HQ" -o printer-is-shared=false

        # "Install HP LaserJet 500 Color M551"
        /usr/sbin/lpadmin -p "HP_LaserJet_500_Color_M551" -E -v "lpd://10.7.1.108" -P /Library/Printers/PPDs/Contents/Resources/HP\ LaserJet\ 500\ color\ M551.gz -D "HP LaserJet 500 Color M551" -L ""Company Location" HQ" -o printer-is-shared=false

        # "Configure default printer"
        sudo -H -u $LoggedInUser /usr/bin/lpoptions -d Lexmark_CX410DE_MFP01
        sudo -H -u $LoggedInUser /usr/bin/defaults write org.cups.PrintingPrefs UseLastPrinter -bool False

      elif [[ "$officeprinters" == "No" ]]; then

        noprint=`$cocoadialog ok-msgbox --no-cancel --string-output  --float --timeout "5" --title "Printer Setup" --text "You've chosen not to install "Company Location" network printers."`

      fi

      # "Install Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/"Company Name"/Software/CharlesProxy/charles-proxy-3.11.6.dmg" > /dev/null
      /bin/cp -R /Volumes/Charles\ Proxy\ v3.11.6/Charles.app "/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.6
      /bin/cp "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
        if [[ "$OS_Version" == "10.12" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        elif [[ "$OS_Version" == "10.12.1" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        elif [[ "$OS_Version" == "10.11.6" ]]; then
          /usr/bin/srm -s "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        fi
      /usr/sbin/chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      /usr/sbin/chown -R $LoggedInUser:staff "/Applications/Charles.app"
      /usr/bin/security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        if [[ "$OS_Version" == "10.12" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        elif [[ "$OS_Version" == "10.12.1" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        elif [[ "$OS_Version" == "10.11.6" ]]; then
          /usr/bin/srm -s "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        fi

      #
      # User Customizations
      #

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
      "$dockutil" --add '/Applications/Charles.app' --before 'System Preferences' --no-restart
      sleep 2 # sleep for two seconds
      
      # Add IntelliJ IDEA CE to dock
      "$dockutil" --add '/Applications/IntelliJ IDEA CE.app' --before 'Charles' --no-restart
      sleep 2 # sleep for two seconds

      # Add PyCharm CE to dock
      "$dockutil" --add '/Applications/PyCharm CE.app' --after 'IntelliJ IDEA CE' --no-restart
      sleep 2 # sleep for two seconds

      # Add Robomongo to dock
      "$dockutil" --add '/Applications/Robomongo.app' --after 'PyCharm CE' --no-restart
      sleep 2 # sleep for two seconds

      # Add Microsoft Visual Studio Code to dock
      "$dockutil" --add '/Applications/Visual Studio Code.app' --after 'Robomongo'
      sleep 2 # sleep for two seconds

      # Add Cisco AnyConnect Secure Mobility Client to dock
      #"$dockutil" --add '/Applications/Cisco/Cisco AnyConnect Secure Mobility Client.app' --after 'Charles'

      #
      # Recursive Permissions Repair of Specific Applications due to inclusion via AutoDMG
      #
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Charles.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Docker.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Firefox.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Google\ Chrome.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Google\ Drive.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Slack.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Sublime\ Text.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/IntelliJ\ IDEA\ CE.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/PyCharm\ CE.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Robomongo.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Visual\ Studio\ Code.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Xcode.app
      #


      # Interactive user input for script processing (in testing...)
      #ben=`$cocoadialog standard-inputbox --title "Information Required" --informative-text "Please enter your email address:"`
      #ben=`$cocoadialog inputbox --title "GitHub Account Information Required" --informative-text "Please enter your email address:" --button1 "OK" --float`
      #button=`echo "${ben}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #StandardInputbox_Output=`echo "${ben}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #jerry=`"$CocoaDialog" secure-standard-inputbox --title "GitHub Account Information Required" --informative-text "Please enter your password:" --string-output --float --icon "Info" --debug`
      #button=`echo "${jerry}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #SecureStandardInputBox_Output=`echo "${jerry}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$StandardInputbox_Output" --icon "info" --timeout "15"
      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$SecureStandardInputBox_Output" --icon "info" --timeout "15"

      #
      # System Customizations
      #

      # Enabled Remote Management via ARDAgent.app/Contents/Resources/kickstart
      "$ardkick" -activate -configure -clientopts -setvnclegacy -vnclegacy -no -setreqperm -reqperm no -setmenuextra -menuextra no
      "$ardkick" -configure -users '"Company Name"admin' -access -on -privs -all 
      "$ardkick" -configure -allowAccessFor -specifiedUsers
      "$ardkick" -restart -agent -menu

      # Interactive user input for local airport code
      airport=`$cocoadialog inputbox --title "Local Airport Code Required" --informative-text "Please enter the 3-digit code of the closest airport:" --button1 "OK" --float --no-cancel`
      #button=`echo "${airport}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      StandardInputbox_Output=`echo "${airport}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      iatacode=`echo $StandardInputbox_Output | tr [a-z] [A-Z]`

      # Set HostName, LocalHostName and ComputerName via scutil
      scutil --set HostName "US$iatacode-$UserInLogged"
      scutil --set LocalHostName "US$iatacode-$UserInLogged"
      scutil --set ComputerName "US$iatacode-$UserInLogged"

      #
      # Determine if the installed apps exist
      #   » If the installed apps exist, then exit with 0
      #   « If the installed apps do not exist, then exit with 1
      #
      declare -xa APPS=('Charles.app' \
                        'Cisco/Cisco AnyConnect Secure Mobility Client.app' \
                        'Docker.app' \
                        'Firefox.app' \
                        'Google Chrome.app' \
                        'Google Drive.app' \
                        'GlobalProtect.app' \
                        'IntelliJ IDEA CE.app' \
                        'PyCharm CE.app' \
                        'Robomongo.app' \
                        'Slack.app' \
                        'Sublime Text.app' \
                        'Visual Studio Code.app' \
                        'Xcode.app' )

      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")

      for app in "${APPS[@]}"; do
        if [[ -d /Applications/"$app" ]]; then
          exit 0
        else
          exit 1
        fi
      done

      IFS=$SAVEIFS

    #
    # This section is intended for the standard image; i.e., non-developer deployment, with Microsoft Office 2016 64-bit
    #
    else

      #
      # If '/Applications/Xcode.app' does not exist then, assuming this computer is running a corporate standard image, 
      # installing the following software:
      #   • Apple HP Printer Drivers v5.0
      #   • Apple Lexmark Printer Drivers v3.1
      #   • Charles Proxy 3.11.6
      #   • Google Hangouts Plugin
      #   • Microsoft Office 2016 for Mac 15.28
      #   • Palo Alto Networks' GlobalProtect VPN Client, Version 3.1.4-7 (No longer installed by Default, but is available for installation)
      #

      # "Xcode was not been found, assuming this is not a developer system..."

      # "Install Palo Alto Networks' GlobalProtect VPN Client..."
      #/usr/sbin/installer -pkg "/Library/"Company Name"/Software/PAN/globalprotect.pkg" -target $3

      # "Install Microsoft Office 2016 15.28..."
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Microsoft/Microsoft_Office_2016_15.28.16111501_Installer.pkg" -target $3

      # Recoup drive space by deleting /Library/"Company Name"/Software/Microsoft/Microsoft_Office_2016_15.28.16111501_Installer.pkg
      /bin/rm -f "/Library/"Company Name"/Software/Microsoft/Microsoft_Office_2016_15.28.16111501_Installer.pkg"

      # "Install Microsoft Delta Update for Outlook 15.26.0 to 15.26.1..."
      #/usr/sbin/installer -pkg "/Library/"Company Name"/Software/Microsoft/Microsoft_Outlook_15.26.1_160916_Updater.pkg" -target $3

      # Recoup drive space by deleting /Library/"Company Name"/Software/Microsoft/Microsoft_Outlook_15.26.1_160916_Updater.pkg
      #/bin/rm -f "/Library/"Company Name"/Software/Microsoft/Microsoft_Outlook_15.26.1_160916_Updater.pkg" -target $3

      # "Install HP Printer Drivers"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/HP/HewlettPackardPrinterDrivers.pkg" -target $3

      # "Install Lexmark Printer Drivers"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Lexmark/LexmarkPrinterDrivers.pkg" -target $3

      # "Install Google Hangouts Plugin"
      /usr/sbin/installer -pkg "/Library/"Company Name"/Software/Google/Google\ Voice\ and\ Video.pkg" -target $3

      # Interactive user input to determine whether or not to install "Company Location" network printers
      smprint=`$cocoadialog yesno-msgbox --no-cancel --string-output --title "Printer Setup" --text "Install and configure "Company Location" network printers?"`

      if [[ "$smprint" == "Yes" ]]; then

        # "Install Lexmark CX410DE MFP 01"
        /usr/sbin/lpadmin -p "Lexmark_CX410DE_MFP01" -E -v "lpd://10.7.10.186" -P /Library/Printers/PPDs/Contents/Resources/Lexmark\ CX410\ Series.gz -D "Lexmark CX410DE MFP01" -L ""Company Location" HQ" -o printer-is-shared=false  

        # "Install HP LaserJet 200 Color MFP 276nw"
        /usr/sbin/lpadmin -p "HP_LaserJet_200_Color_MFP_276nw" -E -v "lpd://10.7.10.45" -P /Library/Printers/PPDs/Contents/Resources/HP\ LaserJet\ 200\ color\ MFP\ M276.gz -D "HP LaserJet 200 Color MFP M276nw" -L ""Company Location" HQ" -o printer-is-shared=false

        # "Install HP LaserJet 500 Color M551"
        /usr/sbin/lpadmin -p "HP_LaserJet_500_Color_M551" -E -v "lpd://10.7.1.108" -P /Library/Printers/PPDs/Contents/Resources/HP\ LaserJet\ 500\ color\ M551.gz -D "HP LaserJet 500 Color M551" -L ""Company Location" HQ" -o printer-is-shared=false

        # "Configure default printer"
        sudo -H -u $LoggedInUser /usr/bin/lpoptions -d Lexmark_CX410DE_MFP01
        sudo -H -u $LoggedInUser /usr/bin/defaults write org.cups.PrintingPrefs UseLastPrinter -bool False

      elif [[ "$smprint" == "No" ]]; then

        noprint=`$cocoadialog ok-msgbox --no-cancel --string-output  --float --timeout "5" --title "Printer Setup" --text "You've chosen not to install "Company Location" network printers."`

      fi

      # "Install Charles Proxy..."
      yes | /usr/bin/hdiutil attach -nobrowse "/Library/"Company Name"/Software/CharlesProxy/charles-proxy-3.11.6.dmg" > /dev/null
      /bin/cp -R /Volumes/Charles\ Proxy\ v3.11.6/Charles.app "/Applications/"
      /usr/bin/hdiutil detach /Volumes/Charles\ Proxy\ v3.11.6
      /bin/cp "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config" "$HOMEDIR"/Library/Preferences
        if [[ "$OS_Version" == "10.12" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        elif [[ "$OS_Version" == "10.12.1" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        elif [[ "$OS_Version" == "10.11.6" ]]; then
          /usr/bin/srm -s "/Library/"Company Name"/Software/CharlesProxy/com.xk72.charles.config"
        fi
      /usr/sbin/chown $LoggedInUser:staff "$HOMEDIR"/Library/Preferences/com.xk72.charles.config
      /usr/sbin/chown -R $LoggedInUser:staff "/Applications/Charles.app"
      /usr/bin/security add-trusted-cert -d -r trustRoot -k "$HOMEDIR"/Library/Keychains/login.keychain "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        if [[ "$OS_Version" == "10.12" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        elif [[ "$OS_Version" == "10.12.1" ]]; then
          /bin/rm -f "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        elif [[ "$OS_Version" == "10.11.6" ]]; then
          /usr/bin/srm -s "/Library/"Company Name"/Software/CharlesProxy/charlesproxy.cer"
        fi

      #
      # User Customizations
      #

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
      "$dockutil" --add '/Applications/Charles.app' --after 'System Preferences'
      sleep 2 # sleep for two seconds

      #
      # Recursive Permissions Repair of Specific Applications due to inclusion via AutoDMG
      #
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Charles.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Firefox.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Google\ Chrome.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Google\ Drive.app
      /usr/sbin/chown -R $LoggedInUser:staff /Applications/Slack.app

      # Interactive user input for script processing (in testing...)
      #ben=`$cocoadialog standard-inputbox --title "Information Required" --informative-text "Please enter your email address:"`
      #ben=`$cocoadialog inputbox --title "GitHub Account Information Required" --informative-text "Please enter your email address:" --button1 "OK" --float`
      #button=`echo "${ben}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #StandardInputbox_Output=`echo "${ben}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #jerry=`"$CocoaDialog" secure-standard-inputbox --title "GitHub Account Information Required" --informative-text "Please enter your password:" --string-output --float --icon "Info" --debug`
      #button=`echo "${jerry}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      #SecureStandardInputBox_Output=`echo "${jerry}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$StandardInputbox_Output" --icon "info" --timeout "15"
      #$cocoadialog bubble --debug --x-placement "left" --y-placement "center" --title "You Entered:" --text "$SecureStandardInputBox_Output" --icon "info" --timeout "15"

      #
      # System Customizations
      #

      # Enabled Remote Management via ARDAgent.app/Contents/Resources/kickstart
      "$ardkick" -activate -configure -clientopts -setvnclegacy -vnclegacy -no -setreqperm -reqperm no -setmenuextra -menuextra no
      "$ardkick" -configure -users 'adminaccount' -access -on -privs -all 
      "$ardkick" -configure -allowAccessFor -specifiedUsers
      "$ardkick" -restart -agent -menu

      # Interactive user input for local airport code
      airport=`$cocoadialog inputbox --title "Local Airport Code Required" --informative-text "Please enter the 3-digit code of the closest airport:" --button1 "OK" --float --no-cancel`
      #button=`echo "${airport}" | awk 'NR>0{print $0}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;
      StandardInputbox_Output=`echo "${airport}" | awk 'NR>1{print $1}' | sed -e 's,.*(\([^<]*\)).*,\1,g'`;

      iatacode=`echo $StandardInputbox_Output | tr [a-z] [A-Z]`

      # Set HostName, LocalHostName and ComputerName via scutil
      scutil --set HostName "US$iatacode-$UserInLogged"
      scutil --set LocalHostName "US$iatacode-$UserInLogged"
      scutil --set ComputerName "US$iatacode-$UserInLogged"

      #
      # Determine if the installed apps exist
      #   » If the installed apps exist, then exit with 0
      #   « If the installed apps do not exist, then exit with 1
      #
      declare -xa APPS=('Charles.app' \
                        'Firefox.app'
                        'Google Chrome.app' \
                        'Google Drive.app' \
                        'Microsoft Excel.app' \
                        'Microsoft Outlook.app' \
                        'Microsoft PowerPoint.app' \
                        'Microsoft Word.app' \
                        'Slack.app' )

      SAVEIFS=$IFS
      IFS=$(echo -en "\n\b")

      for app in "${APPS[@]}"; do
        if [[ -d /Applications/"$app" ]]; then
          exit 0
        else
          exit 1
        fi
      done

      IFS=$SAVEIFS

    fi
