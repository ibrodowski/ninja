#!/bin/bash -e

#
# Original Author : Unknown
# Current Author  : Ian Brodowski
# Last Update     : Friday, August 19, 2016
#
# Change History  :
#   * 20160819    : Modified detection of required installer packages
#   
#   * 20160818    : Reordering of log ($1) echos to just below the function tag
#   
#   * 20160816    : Enhanced debugging and improvements
#                 : Found exit calls were occurring before log calls under checkdependencies()
#                 : Added 'srm -s' to recoup/recover drive space for all installation packages
#                 : Added installhomebrew.sh which is copied to and executes from /usr/local/bin
#                 : Removed references to "$RFK"/7.3
#    
#   * 20160815    : Debugging uncovered some issues within the script, which have since been corrected
#                 : Added Xcode CLT installation for 10.11.6 because it was missing
#    
#   * 20160811    : Added support for OS X 10.11.6
#                 : Re-enabled 'Homebrew' section because it was disabled (most likely due to integration of changes from a forked version)
#    
#   * 20160810    : Added function to backup 'config' and 'known_hosts' into ~/Documents/DevEnv/SSHBackup
#                 : Added installation notification to end of script
#                 : Integrated changes from a forked version (customized version for M.SAMAK) of this script
#
#   * 20160809    : Integrated changes from a forked version (customized version for M.SAMAK) of this script
#
#   * 20160803    : Debugging				
#
#   * 20160802    : Replaced nodejs with nodejs5
#                 :	Replaced npm with npm2
#                 : Replaced phantomjs with phantomjs-prebuilt					
#
#   * 20160617    : Debugging; Random updates to fix known issues.
#
#   * 20160608    : Debugging; Modify .bashrc that's decompressed into ~/
#
#   * 20160606    : Debugging; the generate function was creating the requirements.txt file in $CLIPIT rather than $BIN
#
#   * 20160602    : Debugging
#
#   * 20160506    : Debugging
#                 : Changed pathadd function to write changes to "$HOMEDIR"/.bashrc rather than ~/.bashrc
#                 : Added a check to determine if system variable $DYLD_LIBRARY_PATH exists prior to launching imager
#                 :   If the system variable does not exist then create $DYLD_LIBRARY_PATH system variable and launch imager
#
#   * 20160503    : Debugging
#                 :   Moved generate function after rfkprofile function
#                 : Changed pathadd function to write changes to ~/.bashrc rather than ~/.bash_profile
#                 :   Moved pathadd function to before sourcing activate from $BIN
#                 :
#
#   * 20160502    : Modified argument to exclude -H from $piddir directory creation
#                 :
#
#   * 20160429    : Added method for determining if pidfiles directory exists within $CLIPIT/tools/services/var
#                 :   If it does not exist, create the directory; this directory is required for all services started with development.ini
#                 : Added method for the installation of .bashprofile, .bashrc, .sharc and .ssh into $HOMEDIR
#                 :
#
#   * 20160427    : Added method for installing Reflektion Software.pkg
#                 :
#
#   * 20160426    : Modified method of generating requirements.txt file by removing -H after sudo
#                 : Modified versions for Oracle JDK and JRE from 1.8.0_73 to 1.8.0_91
#                 :
#
#   * 20160425    : Modified method of generating requirements.txt file by preappending sudo -H -u "$SUDO_USER"
#                 : 
#
#   * 20160422    : Bug fixes
#                 : Added function to generate requirements.txt file for pip
#                 : Revised method of modifying setup.py
#                 : Moved git clone for Webology to after all software dependencies have been installed (i.e., git doesn't exist until after Xcode and Xcode command-line tools are installed)
#
#   * 20160411    : Moved if statement for $LoggedInUser right after its enumeration
#                 : Removed support for 10.11.2 and 10.11.3
#                 :
#
#   * 20160404    : Changed version of mongodb to 2.6.11 to match production
#                 : Homebrew has reached version 0.9.9; updated all lines to match
#                 : Commented out all lines under checkdependencies() for running install-dependencies.sh
#                 :   This requirement was abandoned, thus both install.sh and install-dependencies.sh were merged 
#                 :
#
#   * 20160401    : Added git clone for Webology
#                 : 
#                 : 
#
#   * 20160331    : Modified logging directory creation
#                 : 
#                 : 
#
#   * 20160329    : Found a typo for WEBOLOGY
#                 : Updated method for installing XCode Command Line Tools v7.3 for El Capitan 10.11.4
#                 : 
#
#   * 20160301    : Removed unneeded commented out lines
#                 : Removed --system-site-packages
#                 : 
#
#   * 20160226    : Removed unneeded commented out lines
#                 : Removed --system-site-packages
#                 : 
#
#   * 20160224    : Review/Edit
#                 : 
#
#   * 20160222    : Moved all setup.py changes to installdependencies() - if PIL and pywapi are not commented out
#                 :   pip install -e $CLIPIT or . will throw an error
#                 : Uncommented JDK and JRE installation lines under installdependencies()
#                 : 
#
#   * 20160217    : N.Bajaj reported that some packages were not being installed; verified that these missing packages are being installed
#                 : Modify setup.py to comment-out a packaged depencency PIL and pywapi; this is installed using Imaging-1.1.7.tar.gz from
#                 :   effbot.org and pywapi-0.3.8.tar.gz fron launchpad.net
#
#   * 20160216    : Modify setup.py to include explicit version specifiers for pyramid_beaker==0.8, pyramid_debugtoolbar==1.0.6 and pyramid_tm==0.7
#                 : Added check to determine the existence of /Library/RFK, if it does not exist, exit and prompt user
#
#   * 20160212    : Moved variables for all functions under global variables section at the beginning of the script
#                 :
#
#   * 20160211    : Merged install_dependencies.sh as installdependencies()
#                 : Added Imaging-1.1.7.tar.gz and pywapi-0.3.8.tar.gz
#                 : Corrected missing } for log() and main()
#                 : Updated all references of ~ to "$HOMEDIR"
#                 :
#
#   * 20160209    : Added workaround for installing pycurl==7.19 using ARCHFLAGS
#                 : Added workaround for installing gevent==0.13.8 using CFLAGS
#                 : Modified method for adding admin and rfk user(s) to mongodb using mongousers.js
#                 : Recently testing within OS X 10.10.5 (Yosemite)
#                 :   pserve is now functional
#                 : Modified setup.py to include version specific identifiers for pyramid, pyramid_tm, pyramid_beaker and pyramid_debugtoolbar
#                 :   Commented out PIL, because it is installed via requirements.txt
#
#   * 20160208    : Commented out all Xcode and Xcode Command Line Tools checks
#                 :   The reason for commenting all Xcode items is due to a clang error when trying to accept the terms and the subsequent installation of tools by the Xcode.app
#                 :   To that end, Xcode.app will need to be first opened by the user and a manual installation of the Xcode Command Line Tools will also need to be performed by the user 
#                 : Removed double == expressions for 1:1 comparisons and to prevent 'unary operator expected' message from appearing
#                 : 
#
#   * 20160205    : Check bin/* files under Reflektion to ensure that "reflektion" has been replaced with 'current_user_shortname'
#                 :   Exit if it's not the case and prompt to run install_dependencies.sh first
#                 : pip dependency "requests" must be at version 1.1.0
#                 : Moved global variables to the top of the script before any listed functions
#                 : Added new $HOMEDIR variable to find currently logged-in user's home directory
#                 : Removed py-pip and virtualenv as installation within in this script and moved over to install_dependencies.sh
#                 : Added thrift widget benchmark
#                 : 
#        
#   * 20160204    : Found an issue when adding admin and rfk users to mongodb; the db.auth command isn't passed (which is why it fails)
#                 : pip dependency "requests" must be at version 1.1.0
#                 : Corrected incomplete path for virtualenv --system-site-packages
#                 : 
#                 : 
#                 
#   * 20160203    : Include requirements.txt file for install pip dependencies
#                 : Modified sudo command to include -H for all brew install dependencies
#                 : 
#                 : 
#                 
#   * 20160126    : All dependencies must be installed via install_dependencies.sh, before this script is executed
#                 : Ran into an issue with pytz, had to add pip install --upgrade pytz to fix the issue
#                 : Ran into an issue with creating /data/db under root, removed preappended sudo command
#                 : 
#                 :
#
#   * 20160125    : Modified the way virtualenv --system-site-packages command is executed; using "sudo -H -u "$SUDO_USER"" rather than $RunAsUser (i.e., RunAsUser=$(whoami))
#                 :   Added this change as part of two commands, one setting the $UserName variable and then executing the --system-site-packages command
#                 :   Modified all other entries that previously used $RunAsUser, because whoami returns root since the script was executed with sudo
#                 :
#                 : Found two entries for starting mongo_db, redacted the second one on Line 232
#                 :
#
#   * 20160122    : Added rudimentary logging, which logs to config.log under ~/Documents/DevEnv; it provides current position of the script during execution
#                 : Added RunUserAs variable for calls that do not require and/or cannot use sudo (elevated priviledges); e.g., Homebrew
#                 :   This requires the use of sudo -H -u $RunAsUser bash -c 'call or execution of binary and/or command'
#                 :
#                 : Added 'pip install waitress' as a dependency
#                 :
#
#   * 20160121    : Moved subroutines to the top of the script to facilitate proper execution
#                 : i.e., if the call to the subroutines was above the subroutine, it would result in "command not found"
#                 :   Added checkdependencies subroutine to determine if the prerequisites are installed for >>
#                 :   Xcode, Xcode Command Line Tools, MacPorts, Homebrew and mySQL; if they are not installed it will attempt
#                 :   to install them as required.
#                 :
#                 : Modificiation of files within ~/work/Webology/Website/Reflektion/bin now occurs automatically
#                 : 
# 
#   * 20160120    : Added if statement to identify version of OS X, if it does not match 10.10.5, the script exits
#                 : All required additions/changes are now under the subroutine main
# 

# Pre-requisites: 
# OS X 10.11.6, 10.11.5, 10.11.4 or 10.10.5
# Verify installation of Xcode and Xcode command-line tools; open to accept license and install tools
# Verify installation of MacPorts 2.3.4 for OS X 10.10.x (Yosemite) or OS X 10.11.6,5,4 (El Capitan)
# Verify installation of Homebrew 0.9.9
# Verify installation of MySQL 5.5.46 x86_64

# Set global vars
OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
  if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
      LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
  fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
WEBOLOGY="$HOMEDIR"/work/Webology
BIN="$WEBOLOGY"/Website/Reflektion/bin
CLIPIT="$WEBOLOGY"/Website/Reflektion/ClipIt
LIB="$WEBOLOGY"/Website/Reflektion/lib
RFK="/Library/RFK"
CURRENTDIR=$(pwd)
DYLD_PATH=/usr/local/mysql/lib

log() {

  sudo -u "$SUDO_USER" mkdir -p "$HOMEDIR"/Documents/DevEnv
  sudo -u "$SUDO_USER" touch "$HOMEDIR"/Documents/DevEnv/config.log
  LOGNAME="$HOMEDIR"/Documents/DevEnv/config.log

  echo "$1"
  echo "$(date "+%Y-%m-%d %H:%M:%S: ")" "$1" >> "$LOGNAME"

}

rfksshbackup() {

  configfile="$HOMEDIR"/.ssh/config
  knownhostsfile="$HOMEDIR"/.ssh/known_hosts

    if [[ -f "$configfile" && -f "$knownhostsfile" ]]; then
      mkdir -p "$HOMEDIR/Documents/DevEnv/SSHBackup/"
      tobdir="$HOMEDIR"/Documents/DevEnv/SSHBackup
      cp "$configfile" "$tobdir"/
      cp "$knownhostsfile" "$tobdir"/
    else
      log "The files 'config' and 'known_hosts' do not exist, so there isn't anything to backup!!"
    fi
  
}

rfksoftware() {

  rfkpkg="$CURRENTDIR"/Reflektion\ Software.pkg
  if [ -e "$rfkpkg" ]; then
    #echo "Found Reflektion Software.pkg in current directory..."
    log "Found Reflektion Software.pkg in current directory..."
      #echo "Installing Reflektion Software into /Library/RFK..."
      log "Installing Reflektion Software into /Library/RFK..."
      installer -pkg "$rfkpkg" -target /
  else
    #echo "Unable to locate Reflektion Software.pkg, aborting script execution..."
    log "Unable to locate Reflektion Software.pkg, aborting script execution..."
    exit 3
  fi

}

rfkprofile() {

  rfkprofile="$CURRENTDIR"/rfkprofile.zip
  if [ -e "$rfkprofile" ]; then
    #echo "Found Reflektion Profile Package in current directory..."
    log "Found Reflektion Profile Package in current directory..."
      #echo "Decompressing Reflektion Profile Package into $HOMEDIR..."
      log "Decompressing Reflektion Profile Package into $HOMEDIR..."
      sudo -u "$SUDO_USER" unzip -qq "$rfkprofile" -d "$HOMEDIR"
        #echo "Updating .bashrc..."
        log "Updating .bashrc..."
        #sed -i -- "s/reflektion/$LoggedInUser/g" "$HOMEDIR"/.bashrc
        perl -pi -w -e "s/reflektion/$LoggedInUser/g;" "$HOMEDIR"/.bashrc

  else
    #echo "Unable to locate Reflektion Profile Package, aborting script execution..."
    log "Unable to locate Reflektion Profile Package, aborting script execution..."
    exit 4
  fi

}

generate() {

  sudo -u "$SUDO_USER" touch "$BIN"/requirements.txt
  CREATEFILE="$BIN"/requirements.txt

  echo "#" > "$CREATEFILE"
  echo "# Mandatory requirements without version specifiers" >> "$CREATEFILE"
  echo "#" >> "$CREATEFILE"
  echo "cython" >> "$CREATEFILE"
  echo "redis" >> "$CREATEFILE"
  echo "distribute" >> "$CREATEFILE"
  echo "funcsigs" >> "$CREATEFILE"
  echo "gensim" >> "$CREATEFILE"
  echo "pbr" >> "$CREATEFILE"
  echo "mock" >> "$CREATEFILE"
  echo "newrelic" >> "$CREATEFILE"
  echo "geoip2" >> "$CREATEFILE"
  echo "" >> "$CREATEFILE"
  echo "#" >> "$CREATEFILE"
  echo "# Mandatory requirements with version specifiers" >> "$CREATEFILE"
  echo "#" >> "$CREATEFILE"
  echo "scipy==0.14.0" >> "$CREATEFILE"
  echo "scikit-learn==0.15.0" >> "$CREATEFILE"
  echo "numpy==1.8.1" >> "$CREATEFILE"
  echo "jsonschema==2.4.0" >> "$CREATEFILE"
  echo "lxml==2.3.5" >> "$CREATEFILE"
  echo "pyramid==1.3" >> "$CREATEFILE"
  echo "matplotlib==1.4.3" >> "$CREATEFILE"
  echo "user-agents==1.0.1" >> "$CREATEFILE"
  echo "ua-parser==0.4.1" >> "$CREATEFILE"
  echo "pyes==0.20.0" >> "$CREATEFILE"
  echo "planout==0.5" >> "$CREATEFILE"
  echo "" >> "$CREATEFILE"
  echo "#" >> "$CREATEFILE"
  echo "# Specific files" >> "$CREATEFILE"
  echo "#" >> "$CREATEFILE"
  echo "git+git://github.com/bbangert/beaker_extensions.git" >> "$CREATEFILE"
  
}

updatepaths() {

  LINE1="export PATH=\${PATH}:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin"
  LINE2="export DYLD_LIBRARY_PATH=/usr/local/mysql/lib"

  if [ ! -e "$HOMEDIR"/.bashrc ]; then
    sudo -u "$SUDO_USER" touch "$HOMEDIR"/.bashrc
  fi

  grep -qsFx "$LINE1" "$HOMEDIR"/.bashrc || sudo -u "$SUDO_USER" printf "%s\n" "$LINE1" >> "$HOMEDIR"/.bashrc
  grep -qsFx "$LINE2" "$HOMEDIR"/.bashrc || sudo -u "$SUDO_USER" printf "%s\n" "$LINE2" >> "$HOMEDIR"/.bashrc

  pathadd() {
      if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
          PATH="${PATH:+"$PATH:"}$1"
      fi
  }

  pathadd /usr/local/mysql/bin
  pathadd /usr/local/bin
  pathadd /opt/local/bin
  pathadd /opt/local/sbin
  log "Updating paths for $DYLD_LIBRARY_PATH and $PATH..."

}

installdependencies() {

  #echo "Installing mandatory dependencies..."
  log "Installing mandatory dependencies..."

  # Check for /Library/RFK, if it does not exist, prompt user.
  if [[ -e "$RFK"/Webology/Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg && -e "$RFK"/Webology/Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg && -e "$RFK"/Webology/JDK\ 8\ Update\ 91.pkg && -e "$RFK"/Webology/MacPorts-2.3.4-10.10-Yosemite.pkg && -e "$RFK"/Webology/MacPorts-2.3.4-10.11-ElCapitan.pkg && -e "$RFK"/Webology/mysql-5.5.46-osx10.8-x86_64.pkg && -e "$RFK"/Webology/OracleJava8-1.8.91.14.pkg ]]; then
    log "The files exist!!!"
    rfksshbackup
    #rfksoftware
    rfkprofile
  else
    log "Unable to locate required RFK Software directory under /Library/RFK, installing Reflektion Software.pkg..."
    rfksshbackup
    rfksoftware
    rfkprofile
  fi

  # Install Xcode and Command Line Tools
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
    if [ -e "$xcodeapp" ]; then
      if [ "$XcodeInstalled" == "/Applications/Xcode.app/Contents/Developer" ]; then
        #echo "Xcode is installed, opening Xcode for user to accept license and have Xcode install its components..."
        log "Xcode is installed, opening Xcode for user to accept license and have Xcode install its components..."
        sudo -H -u "$SUDO_USER" bash -c "open -W $xcodeapp"
        #echo "Installing Xcode Command Line Tools..."
        pushd $RFK/
          if [ "$OS_Version" == "10.10.5" ]; then
              #echo "Installing Command Line Tools for Yosemite..."
              log "Installing Command Line Tools for Yosemite..."
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /
              srm -s Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg
          elif [ "$OS_Version" == "10.11.4" ]; then
              #echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              srm -s Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg
          elif [ "$OS_Version" == "10.11.5" ]; then
              #echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              srm -s Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg
          elif [ "$OS_Version" == "10.11.6" ]; then
              #echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              srm -s Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg
          fi
        popd
      fi
  else
    #echo "Xcode is not installed, please install Xcode..."
    log "Xcode is not installed, please install Xcode..."
    exit 4
  fi

  #echo "Create local directory for Webology..."
  log "Create local directory for Webology..."
  sudo -u "$SUDO_USER" mkdir -p "$HOMEDIR/work/Webology/"

  #echo "Clone Reflektion/Webology from GitHub to local system..."
  log "Clone Reflektion/Webology from GitHub to local system..."
  sudo -H -u "$SUDO_USER" git clone https://github.com/Reflektion/Webology.git "$HOMEDIR"/work/Webology/

  # Install mySQL 5.5.46
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  if [ -f "$mysqlbinary" ]; then
      #echo "mySQL is installed, checking version..."
      log "mySQL is installed, checking version..."
      mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
      if [ "$mySQLInstalled" = "5.5.46" ]; then
        #echo "mySQL 5.5.46 is installed."
        log "mySQL 5.5.46 is installed."
      fi
  else
    #echo "mySQL 5.5.46 is not installed, running installation..."
    log "mySQL 5.5.46 is not installed, attempting to install..."
    pushd $RFK/
    installer -pkg mysql-5.5.46-osx10.8-x86_64.pkg -target /
    srm -s mysql-5.5.46-osx10.8-x86_64.pkg
    popd
  fi

  # Install MacPorts
  log "Checking MacPorts installation..."
  portbinary="/opt/local/bin/port"
  if [ -f "$portbinary" ]; then
    #echo "Port is installed, checking version..."
      PortInstalled=$(port version | awk '{print $2}')
      if [ "$PortInstalled" = "2.3.4" ]; then
        #echo "MacPorts 2.3.4 is installed."
        log "MacPorts 2.3.4 is installed."
      fi
  else
    #echo "MacPorts 2.3.4 is not installed, running installation..."
      pushd $RFK/
      if [ "$OS_Version" == "10.10.5" ]; then
          log "MacPorts 2.3.4 is not installed, attempting install for Yosemite..."
          installer -pkg MacPorts-2.3.4-10.10-Yosemite.pkg -target /
          srm -s MacPorts-2.3.4-10.10-Yosemite.pkg
          sudo -H -u "$SUDO_USER" bash -c 'export PATH=/opt/local/bin:opt/local/sbin:$PATH'
          export PATH=/opt/local/bin:opt/local/sbin:$PATH
      elif [ "$OS_Version" == "10.11.4" ]; then
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
          installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          srm -s MacPorts-2.3.4-10.11-ElCapitan.pkg
          sudo -H -u "$SUDO_USER" bash -c 'export PATH=/opt/local/bin:opt/local/sbin:$PATH'
          export PATH=/opt/local/bin:opt/local/sbin:$PATH
      elif [ "$OS_Version" == "10.11.5" ]; then
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
          installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          srm -s MacPorts-2.3.4-10.11-ElCapitan.pkg
          sudo -H -u "$SUDO_USER" bash -c 'export PATH=/opt/local/bin:opt/local/sbin:$PATH'
          export PATH=/opt/local/bin:opt/local/sbin:$PATH
      elif [ "$OS_Version" == "10.11.6" ]; then
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
          srm -s MacPorts-2.3.4-10.11-ElCapitan.pkg
          installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          sudo -H -u "$SUDO_USER" bash -c 'export PATH=/opt/local/bin:opt/local/sbin:$PATH'
          export PATH=/opt/local/bin:opt/local/sbin:$PATH
      fi
      popd
  fi

  # Install Homebrew
  log "Checking Homebrew installation..."
  brewbinary="/usr/local/bin/brew"
  if [ -f "$brewbinary" ]; then
    #echo "Homebrew is installed, checking version..."
    log "Homebrew is installed, checking version..."
      HomebrewInstalled=$(brew --version | awk '{print $2}')
      if [ "$HomebrewInstalled" = "0.9.9" ]; then
          #echo "Homebrew 0.9.9 is installed."
          log "Homebrew 0.9.9 is installed"
        fi
  else
    #echo "Homebrew 0.9.9 is not installed, running installation..."
    log "Homebrew 0.9.9 is not installed, attempting install..."
    #cp "$RFK"/Webology/bin/scpt/installhomebrew.sh /usr/local/bin/
    #chmod +x /usr/local/bin/installhomebrew.sh
    #sudo -H -u "$SUDO_USER" bash -c './usr/local/bin/installhomebrew.sh'
    #srm -s /usr/local/bin/installhomebrew.sh
    sudo -H -u "$SUDO_USER" bash -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
  fi

  # Install virtualenv globally and set VIRTUALENV to ~/work/Webology/Website/Reflektion
  #echo "Installing virtualenv 1.1.0 and setting virtualenv path..."
  log "Installing virtualenv 1.1.0 and setting virtualenv path..."
  curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.10.1.tar.gz
  tar xvfz virtualenv-1.10.1.tar.gz
  cd virtualenv-1.10.1
  python setup.py install
  cd -
  sudo -H -u "$SUDO_USER" /usr/local/bin/virtualenv "$HOMEDIR"/work/Webology/Website/Reflektion #--system-site-packages


  #
  # Check to see if port is available before installing py-pip and python27
  #
  if ! type "port" 2>/dev/null >/dev/null; then
    #echo "The MacPorts installation may have succeeded, but the PATH variable was not update updated."
    log "The MacPorts installation may have succeeded, but the PATH variable was not update updated."
    exit 5
  else
    # Install py-pip and python27 within ~/work/Webology/Website/Reflektion/bin
    #echo "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
    log "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
    pushd "$WEBOLOGY"/Website/Reflektion/bin/
    #echo "Installing py-pip and python27 via port..."
    log "Installing py-pip and python27 via port..."
    port install py-pip
    port install python27
    popd
  fi

  # Install Java Runtime Environment
  # Disabled version checking as it may prompt the user to install from Apple's website and/or may return an unexpected or unwanted error
  log "Installing Java Runtime Environment 1.8.0_91..."
  #jrebinary="/usr/bin/java"
  #  if [ -f "$jrebinary" ]; then
  #    jreinstalled=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
  #    if [ "$jreinstalled" = "1.8.0_91" ]; then
  #      #echo "Java Runtime Environment 1.8.0_91 is installed."
  #      log "Java Runtime Environment 1.8.0_91 is installed."
  #    fi
  #  else
      pushd $RFK/
      #echo "Java Runtime Environment is not installed, running installation..."
      log "Java Runtime Environment is not installed, running installation..."
      installer -pkg OracleJava8-1.8.91.14.pkg -target /
      srm -s OracleJava8-1.8.91.14.pkg
      popd
  #  fi

  # Install Java Development Kit
  # Disabled version checking as it may prompt the user to install from Apple's website and/or may return an unexpected or unwanted error
  log "Installing Java Development Kit 1.8.0_91..."
  #jdkbinary="/usr/bin/javac"
  #  if [ -f "$jdkbinary" ]; then
  #    jreinstalled=$(javac -version 2>&1 | awk '{print $2}')
  #    if [ "$jreinstalled" = "1.8.0_91" ]; then
  #      #echo "Java Development Kit 1.8.0_91 is installed."
  #      log "Java Development Kit 1.8.0_91 is installed."
  #    fi
  #  else
      pushd $RFK/
      #echo "Java Runtime Development Kit is not installed, running installation..."
      log "Java Runtime Development Kit is not installed, running installation..."
      installer -pkg JDK\ 8\ Update\ 91.pkg -target /
      srm -s JDK\ 8\ Update\ 91.pkg
      popd
  #  fi

  #
  # Update setup.py (ClipIt)
  #

  #echo "Checking for the existence of setup.py..."
  log "Checking for the existence of setup.py..."
  setuppy="$CLIPIT"/setup.py
    if [ -e "$setuppy" ]; then
      #echo "Found setup.py, processing changes..."
      log "Found setup.py, processing changes..."
      #Modify setup.py to include explicit version specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm
      ##echo "Updating setup.py to include explicit version specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm"
      #log "Updating setup.py to include explicit version specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm"
      #perl -pi -w -e "s/'pyramid_beaker',/'pyramid_beaker==0.8',/g;" "$CLIPIT"/setup.py
      #perl -pi -w -e "s/'pyramid_debugtoolbar',/'pyramid_debugtoolbar==1.0.6',/g;" ""$CLIPIT"/setup.py"
      #perl -pi -w -e "s/'pyramid_tm',/'pyramid_tm==0.7',/g;" "$CLIPIT"/setup.py

      # Modify setup.py to remove dependency on pywapi, which was replaced with pywapi-0.38.0.tar.gz
      ##echo "Modify setup.py to remove dependency on pywapi, which was replaced with pywapi-0.38.0.tar.gz..."
      #log "Modify setup.py to remove dependency on pywapi, which was replaced with pywapi-0.38.0.tar.gz..."
      #perl -pi -w -e "s/'pywapi',/#'pywapi',/g;" "$CLIPIT"/setup.py

      # Modify setup.py to remove dependency on PIL, which was replaced with Imaging-1.1.7.tar.gz
      #echo "Modify setup.py to remove dependency on PIL, which was replaced with Imaging-1.1.7.tar.gz..."
      log "Modify setup.py to remove dependency on PIL, which was replaced with Imaging-1.1.7.tar.gz..."
      perl -pi -w -e "s/'PIL==1.1.7',/#'PIL==1.1.7',/g;" "$CLIPIT"/setup.py
    else
      #echo "Unable to locate setup.py, required changes cannot be applied..."
      log "Unable to locate setup.py, required changes cannot be applied..."
    fi

  #
  # Generate requirements.txt file in $BIN
  #
  #echo "Generating requirements.txt file in $BIN..."
  log "Generating requirements.txt file in $BIN..."
  generate

}

checkdependencies() {

  #echo "Checking existence of mandatory dependencies..."
  log "Checking existence of mandatory dependencies..."

  # Check for Xcode.app
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
  if [ -e "$xcodeapp" ]; then
      if [ "$XcodeInstalled" == "/Applications/Xcode.app/Contents/Developer" ]; then
        #echo "Xcode.app is installed."
        log "Xcode.app is installed."
      fi
  else
      #echo "Xcode is not installed, prompting user..."
      #echo "Please manually install Xcode.app and the Xcode Command Line Tools before running this script..."
      log "Xcode is not installed, prompting user..."
      log "Please manually install Xcode.app and the Xcode Command Line Tools before running this script..."
      exit 5
  fi

  # Check for mySQL 5.5.46 installation
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  if [ -f "$mysqlbinary" ]; then
      mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
      if [ "$mySQLInstalled" = "5.5.46" ]; then
        #echo "mySQL 5.5.46 is installed."
        log "mySQL 5.5.46 is installed."
      fi
  else
      #echo "mySQL 5.5.46 is not installed, prompting user..."
      ##echo "Please run the install-dependencies.sh script before running this script..."
      log "mySQL 5.5.46 is not installed, prompting user..."
      exit 6
  fi

  # Check for MacPorts installation
  log "Checking MacPorts installation..."
  portbinary="/opt/local/bin/port"
  if [ -f "$portbinary" ]; then
    #echo "Port is installed, checking version..."
      PortInstalled=$(port version | awk '{print $2}')
      if [ "$PortInstalled" = "2.3.4" ]; then
        #echo "MacPorts 2.3.4 is installed."
        log "MacPorts 2.3.4 is installed."
      fi
  else
    #echo "MacPorts 2.3.4 is not installed, running installation..."
    ##echo "Please run the install-dependencies.sh script before running this script..."
    log "MacPorts 2.3.4 is not installed, prompting user..."
    exit 7
  fi

  # Check for Homebrew installation
  log "Checking Homebrew installation..."
  brewbinary="/usr/local/bin/brew"
  if [ -f "$brewbinary" ]; then
    #echo "Homebrew is installed, checking version..."
      HomebrewInstalled=$(brew --version | awk '{print $2}')
      if [ "$HomebrewInstalled" = "0.9.9" ]; then
          #echo "Homebrew 0.9.9 is installed."
          log "Homebrew 0.9.9 is installed."
      fi
  else
    #echo "Homebrew 0.9.9 is not installed, prompting user..."
    ##echo "Please run the install-dependencies.sh script before running this script..."
    log "Homebrew 0.9.9 is not installed, prompting user..."
    exit 8
  fi

  # Check for Java Runtime Environment installation
  log "Checking Java Runtime Environment installation..."
  jrebinary="/usr/bin/java"
    if [ -f "$jrebinary" ]; then
      jreinstalled=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
      if [ "$jreinstalled" = "1.8.0_91" ]; then
        #echo "Java Runtime Environment 1.8.0_91 is installed."
        log "Java Runtime Environment 1.8.0_91 is installed."
      fi
    else
      #echo "Java Runtime Environment is not installed, prompting user..."
      ##echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Environment is not installed, prompting user..."
      exit 9
    fi

  # Check for Java Development Kit installation
  log "Checking Java Development Kit installation..."
  jdkbinary="/usr/bin/javac"
    if [ -f "$jdkbinary" ]; then
      jreinstalled=$(javac -version 2>&1 | awk '{print $2}')
      if [ "$jreinstalled" = "1.8.0_91" ]; then
        #echo "Java Development Kit 1.8.0_91 is installed."
        log "Java Development Kit 1.8.0_91 is installed."
      fi
    else
      #echo "Java Runtime Development Kit is not installed, prompting user..."
      ##echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Development Kit is not installed, prompting user..."
      exit 1
    fi

}

main() {

  #echo "Running main functions..."
  log "Running main functions..."

  # Install dependencies using MacPorts
  port install boost
  port install curl # unsure if this is required since there's a system level version available
  port install jpeg
  port install libevent
  port install libpng
  port install lcms
  port install nodejs5
  port install npm2
  #echo "Installing boost, curl, jpeg, libevent, libpng, lcms, nodejs and npm via port..."
  log "Installing boost, curl, jpeg, libevent, libpng, lcms, nodejs and npm via port..."

  #
  # Update paths
  #
  #echo "Updating paths before sourcing activate from $BIN..."
  log "Updating paths before sourcing activate from $BIN..."
  updatepaths

  # Activate virtual environment
  source "$BIN"/activate
  #echo "Activate virtual environment"
  log "Activate virtual environment"

  # Install dependencies using pip
  sudo -H -u "$SUDO_USER" "$BIN"/easy_install pip
  sudo -H -u "$SUDO_USER" "$BIN"/pip install --upgrade pip
  sudo -H -u "$SUDO_USER" "$BIN"/pip install --upgrade setuptools
  sudo -H -u "$SUDO_USER" "$BIN"/pip install --upgrade pytz
  sudo -H -u "$SUDO_USER" bash -c 'env ARCHFLAGS="-arch x86_64" pip install pycurl==7.19'
  sudo -H -u "$SUDO_USER" bash -c 'CFLAGS="-I /opt/local/include -L /opt/local/lib" pip install gevent==0.13.8'
  sudo -H -u "$SUDO_USER" "$BIN"/pip install http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz
  sudo -H -u "$SUDO_USER" "$BIN"/pip install https://launchpad.net/python-weather-api/trunk/0.3.8/+download/pywapi-0.3.8.tar.gz
  sudo -H -u "$SUDO_USER" "$BIN"/pip install -r "$BIN"/requirements.txt
  #echo "Installing mandatory pip dependencies via requirements file..."
  log "Installing mandatory pip dependencies via requirements file..."

  # Install dependencies using Homebrew
  sudo -H -u "$SUDO_USER" brew doctor
  sudo -H -u "$SUDO_USER" brew install freetype
  sudo -H -u "$SUDO_USER" brew install thrift
  sudo -H -u "$SUDO_USER" brew install homebrew/versions/mongodb26
  sudo -H -u "$SUDO_USER" brew install homebrew/versions/redis26
  #echo "Installing freetype, thrift, mongodb24 and redis26 via brew..."
  log "Installing freetype, thrift, mongodb24 and redis26 via brew..."

  # Install phantomjs with npm
  npm -g install phantomjs-prebuilt
  #echo "Installing phantomjs via npm..."
  log "Installing phantomjs via npm..."

  # Create symlink for freetype under /opt/local/include/freetype
  #echo "Creating symlink for freetype..."
  log "Creating symlink for freetype..."
  ln -s /opt/local/include/freetype2 /opt/local/include/freetype

  # Invoke setup.py after installing all required dependencies
  #echo "Invoke setup.py to install ClipIt dependencies, after installing all base dependencies..."
  log "Invoke setup.py to install ClipIt dependencies, after installing all base dependencies..."
  sudo -H -u "$SUDO_USER" "$BIN"/pip install -e "$CLIPIT" #--process-dependency-links --allow-all-external # or "$BIN"/pip install -e .

  # Decompress mongo dump into /data/db
  #echo "Decompress mongo dump into /data/db..."
  log "Decompress mongo dump into /data/db..."
  mkdir -p /data/db
  chmod 777 /data
  chmod 777 /data/db
  pushd /data/db
  gzip -dc "$HOMEDIR"/data/Backup/mongo_dump.tgz | tar xvf -
  popd

  #
  # Ensure that the directory pidfiles exists within ~/work/Webology/Website/Reflektion/ClipIt/tools/services/var/
  #
  piddir="$CLIPIT"/tools/services/var/pidfiles
  if [ -d "$piddir" ]; then
    #echo "The pidfiles directory exists within $CLIPIT/tools/services/var/..."
    log "The pidfiles directory exists within $CLIPIT/tools/services/var/..."
  else
    #echo "The pidfiles directory does not exist within $CLIPIT/tools/services/var/, creating directory..."
    log "The pidfiles directory does not exist within $CLIPIT/tools/services/var/, creating directory..."
    sudo -u "$SUDO_USER" mkdir -p "$piddir"
  fi

  # Start mongodb services and add users
  #echo "Start mongodb and create users..."
  log "Start mongodb and create users..."
  "$CLIPIT"/tools/services/mongo_db/server.py "$CLIPIT"/development.ini start
  echo "use admin" > mongousers.js
  echo "db.addUser(\"admin\", \"admin\")" >> mongousers.js
  echo "db.auth(\"admin\", \"admin\")" >> mongousers.js
  echo "use rfk" >> mongousers.js
  echo "db.addUser(\"rfk\", \"rfk789\")" >> mongousers.js
  mongo < mongousers.js
  rm mongousers.js

  # Install ElasticSearch
  #echo "Install ElasticSearch..."
  log "Install ElasticSearch..."
  pushd "$CLIPIT"/tools/services/es_helper/
  ./install_elasticsearch.sh
  popd

  # Import mySQL dump from ~/data/Backup/mysql_dump.sql
  #echo "Import mySQL dump from ~/data/Backup..."
  log "Import mySQL dump from ~/data/Backup..."
  /usr/local/mysql/support-files/mysql.server start
  sudo -H -u "$SUDO_USER" mysql -u root -h localhost < "$HOMEDIR"/data/Backup/mysql_dump.sql

  # Import redis dump from ~/data/Backup/redis_dump.tgz
  #echo "Decompress redis dump from ~/data/Backup..."
  log "Decompress redis dump from ~/data/Backup..."
  mkdir -p "$CLIPIT"/tools/services/var/storage/redis/
  pushd "$CLIPIT"/tools/services/var/storage/redis/
  gzip -dc "$HOMEDIR"/data/Backup/redis_dump.tgz | tar xvf -
  popd

  # Start required dependencies and/or services
  #echo "Starting redis and mailer..."
  log "Starting redis and mailer..."
  sudo -u "$SUDO_USER" "$CLIPIT"/tools/services/redis/redis.py "$CLIPIT"/development.ini start || true
  sudo -u "$SUDO_USER" "$CLIPIT"/tools/services/workers/mailer.py "$CLIPIT"/development.ini start || true

  #
  # Confirm DYLD_LIBRARY_PATH system variable exists, if not create system variable, then launch imager.
  #
  install_name_tool -change libmysqlclient.18.dylib /usr/local/mysql/lib/libmysqlclient.18.dylib "$LIB"/python2.7/site-packages/_mysql.so
  sudo -u "$SUDO_USER" "$CLIPIT"/tools/services/workers/imager.py "$CLIPIT"/development.ini start || true  

  # Configure thrift
  #echo "Configuring thrift..."
  log "Configuring thrift..."
  pushd "$CLIPIT"
  thrift --gen py -out . "$CLIPIT"/thriftService.thrift
  popd

  # Configure thrift widget benchmark
  #echo "Configuring thrift widget benchmark..."
  log "Configuring thrift widget benchmark..."
  pushd "$CLIPIT"/tools/services/customers/widget_benchmark
  thrift --gen py -out . WidgetBenchmark.thrift
  popd

  # Update connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/
  #echo "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."
  log "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."
  perl -pi -w -e 's/calling_format=DefaultCallingFormat/calling_format=OrdinaryCallingFormat()/g;' "$HOMEDIR"/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/connection.py

  # Clear screen to reveal custom exit message
  clear

  #
  # Custom Exit Message
  #
  echo ""
  echo "##########################"
  echo "# INSTALLATION COMPLETE! #"
  echo "##########################"
  echo "#"
  echo "# The setup and installation of the local development environment has completed."
  echo "#"
  echo "# The files '~/.ssh/config' and '~/.ssh/known_hosts' were backed up to"
  echo "# » '~/Documents/DevEnv/SSHBackup'"
  echo "#"
  echo "# Before attempting to run pserve locally, please perform the following:"
  echo "# • Quit and relaunch Terminal"
  echo "# • Add your AWS information to:"
  echo "#   '~/work/Webology/Website/Reflektion/ClipIt/development.ini'"
  echo "# • Use 'activate' to access the virtual environment"
  echo "#"
  echo "# After performing the items above, you can then attempt running:"
  echo "# 'pserve $CLIPIT/development.ini'"
  echo "#"
  echo "# Thank you for using the TechOps local development installation script,"
  echo "# brought to you by Ian Brodowski and unknown authors!!"
  echo ""

  exit 0

}

if [ $UID != 0 ]; then
  #echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == "10.10.5" ]]; then
   #echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.4" ]]; then
   #echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.5" ]]; then
   #echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.6" ]]; then
   #echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
else
   #echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   log "Unsupported operating system version detected..."
   exit 2
fi
