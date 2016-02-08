#!/bin/bash

#
# Author		      : Ian Brodowski
# Script Name     : install_dependencies.sh
# Script Purpose  :	Installs all dependencies as required by install.sh
#                 :   Such as the following:
#                 :   Xcode 7.2, Xcode command-line tools for Yosemite or El Capitan, mySQL 5.5.46, MacPorts 2.3.4, Homebrew 0.9.5 and Python 2.7 (via port)
#
# Last Update     : Monday, February 8, 2016
#
# Change History  :
#   * 20160208    : Removed "sudo -H -u $SUDO_USER bash -c" from all installation routines that use installer to install a pkg
#                 : On Friday, February 8, 2016, found an open if statement, which caused an error when running the script
#                 : Commented out all Xcode and Xcode Command Line Tools checks and intallation routines
#                 :   The reason for commenting all Xcode items is due to a clang error when trying to accept the terms and the subsequent installation of tools by the Xcode.app
#                 :   To that end, Xcode.app will need to be first opened by the user and a manual installation of the Xcode Command Line Tools will also need to be performed by the user 
#                 : Removed double == expressions for 1:1 comparisons and to prevent 'unary operator expected' message from appearing
#                 :
#
#   * 20160205    : Added new $HOMEDIR variable to find currently logged-in user's home directory
#                 : Modified virtualenv to be installed globally in /usr/local/bin
#                 : 
#                 : 
#
#   * 20160204    : Added JRE and JDK checks and installation routines
#                 : Modified virtualenv to be installed globally in /usr/local/bin
#                 : 
#                 : 
#
#   * 20160204    : Modified check for Xcode
#                 : Changed paths for pkgs
#                 : Added port install py-pip in addition to python27 for ~work/Webology/Website/Reflektion/bin
#
#   * 20160129    : Refinements
#                 : 
#
#   * 20160126    : Script inception
#                 : 
#

# Set global vars
OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')

log() {

  mkdir -p "$HOMEDIR"/Documents/DevEnv
  touch "$HOMEDIR"/Documents/DevEnv/dependencies.log
  LOGNAME="$HOMEDIR"/Documents/DevEnv/dependencies.log

  echo $1
  echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $LOGNAME

}

checkdependencies() {

  log "Checking dependencies..."

  # Set function variables
  WEB="$HOMEDIR"/work/Webology
  RFK=/Library/RFK
  log "Setting local variables for dependencies check..."

  echo "Checking mandatory dependencies..."

  # Update directory paths for all files in ~/work/Webology/Website/Reflektion/bin
  log "Update directory paths in files located in bin..."
  Readline=$(head -1 $WEB/Website/Reflektion/bin/asadmin)
  if [ $Readline = "#!/Users/reflektion/work/Webology/Website/Reflektion/bin/python" ]; then
    echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" has not been updated, applying changes..."
    pushd $WEB/Website/Reflektion/
    perl -pi -w -e 's/reflektion/$ENV{'LOGNAME'}/g;' bin/*
    popd
    log "Directory paths update completed."
  else
   echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" have already been updated."
   log "The directory paths for all files in bin have already been updated."
  fi

  # Install Xcode and Command Line Tools
#  log "Checking Xcode installation..."
#  XcodeInstalled=$(xcode-select -p)
#  xcodeapp="/Applications/Xcode.app"
#    if [ -e $xcodeapp ]; then
#      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
#        echo "Xcode is installed."
#        log "Xcode is installed."
#        xcrun cc
#        echo "Installing Xcode Command Line Tools..."
#        pushd $RFK/
#          if [ $OS_Version == '10.10.5' ]; then
#              sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /'
#              echo "Installing Command Line Tools for Yosemite..."
#              log "Installing Command Line Tools for Yosemite..."
#          elif [ $OS_Version == '10.11.2' ]; then
#              sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /'
#              echo "Installing Command Line Tools for El Capitan..."
#              log "Installing Command Line Tools for El Capitan..."
#          elif [ $OS_Version == '10.11.3' ]; then
#              sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /'
#              echo "Installing Command Line Tools for El Capitan..."
#              log "Installing Command Line Tools for El Capitan..."
#          fi
#        popd
#      fi
#  else
#    echo "Xcode and Command Line Tools are not installed, running Xcode wizard..."
#    log "Xcode is not installed, attempting to install..."
#    sudo xcode-select --install || true
#      pushd $RFK/
#        if [ $OS_Version == '10.10.5' ]; then
#            sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /'
#            log "Installing Command Line Tools for Yosemite..."
#        elif [ $OS_Version == '10.11.2' ]; then
#            sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /'
#            log "Installing Command Line Tools for El Capitan..."
#        elif [ $OS_Version == '10.11.3' ]; then
#            sudo -H -u $SUDO_USER bash -c 'installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /'
#            log "Installing Command Line Tools for El Capitan..."
#        fi
#      popd
#  fi

  # Install mySQL 5.5.46
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
  if [ $mySQLInstalled = "5.5.46" ]; then
    echo "mySQL 5.5.46 is installed."
    log "mySQL 5.5.46 is installed."
  else
    echo "mySQL 5.5.46 is not installed, running installation..."
    pushd $RFK/
    installer -pkg mysql-5.5.46-osx10.9-x86_64.pkg -target /
    popd
    log "mySQL 5.5.46 is not installed, attempting to install..."
  fi

  # Install MacPorts
  log "Checking MacPorts installation..."
  portbinary="/opt/local/bin/port"
  if [ -f $portbinary ]; then
    echo "Port is installed, checking version..."
      PortInstalled=$(port version | awk '{print $2}')
      if [ $PortInstalled = "2.3.4" ]; then
        echo "MacPorts 2.3.4 is installed."
        log "MacPorts 2.3.4 is installed."
      fi
  else
    echo "MacPorts 2.3.4 is not installed, running installation..."
      pushd $RFK/
      if [ $OS_Version == "10.10.5" ]; then
          installer -pkg MacPorts-2.3.4-10.10-Yosemite.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for Yosemite..."
      elif [ $OS_Version == "10.11.2" ]; then
          installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
      elif [ $OS_Version == "10.11.3" ]; then
          installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
      fi
      log "MacPorts 2.3.4 is not installed, attempting install..."
      popd
  fi

  # Install Homebrew
  log "Checking Homebrew installation..."
  brewbinary="/usr/local/bin/brew"
  if [ -f $brewbinary ]; then
  	echo "Homebrew is installed, checking version..."
    	HomebrewInstalled=$(brew --version | awk '{print $2}')
    	if [ $HomebrewInstalled = "0.9.5" ]; then
      	  echo "Homebrew 0.9.5 is installed."
          log "Homebrew 0.9.5 is installed"
        fi
  else
    echo "Homebrew 0.9.5 is not installed, running installation..."
    sudo -H -u $SUDO_USER bash -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    log "Homebrew 0.9.5 is not installed, attempting install..."
  fi

  # Install virtualenv globally and set system-site-packages to ~/work/Webology/Website/Reflektion
  curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.10.1.tar.gz
  tar xvfz virtualenv-1.10.1.tar.gz
  cd virtualenv-1.10.1
  python setup.py install
  cd -
  sudo -H -u $SUDO_USER /usr/local/bin/virtualenv --system-site-packages "$HOMEDIR"/work/Webology/Website/Reflektion
  echo "Installing virtualenv 1.1.0 and setting system-site-packages..."
  log "Installing virtualenv 1.1.0 and setting system-site-packages..."

  # Install py-pip and python27 within ~/work/Webology/Website/Reflektion/bin
  pushd $WEB/Website/Reflektion/bin/
  echo "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
  log "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
  port install py-pip
  port install python27
  echo "Installing py-pip and python27 into ~/work/Webology/Website/Reflektion/bin via port..."
  log "Installing py-pip and python27 into ~/work/Webology/Website/Reflektion/bin via port..."
  popd

  # Install Java Runtime Environment
  log "Checking Java Runtime Environment installation…"
  jrebinary="/usr/bin/java"
    if [ -f $jrebinary ]; then
      #jreinstalled=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
      #if [ $jreinstalled = "1.8.0_73" ]; then
      #  echo "Java Runtime Environment 1.8.0_73 is installed."
      #  log "Java Runtime Environment 1.8.0_73 is installed."
      #fi
    #else
      pushd $RFK/
      echo "Java Runtime Environment is not installed, running installation..."
      log "Java Runtime Environment is not installed, running installation..."
      installer -pkg OracleJava8-1.8.73.02.pkg -target /
      popd
    fi

  # Install Java Development Kit
  log "Checking Java Development Kit installation…"
  jdkbinary="/usr/bin/javac"
    if [ -f $jfkbinary ]; then
      #jreinstalled=$(javac -version 2>&1 | awk '{print $2}')
      #if [ $jreinstalled = "1.8.0_73" ]; then
      #  echo "Java Development Kit 1.8.0_73 is installed."
      #  log "Java Development Kit 1.8.0_73 is installed."
      #fi
    #else
      pushd $RFK/
      echo "Java Runtime Development Kit is not installed, running installation..."
      log "Java Runtime Development Kit is not installed, running installation..."
      installer -pkg JDK\ 8\ Update\ 73.pkg -target /
      popd
    fi

}

if [ $UID != 0 ]; then
  echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == 10.10.5 ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   checkdependencies
elif [[ ${OS_Version} == 10.11.2 ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..." 
   checkdependencies
elif [[ ${OS_Version} == 10.11.3 ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..." 
   checkdependencies
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   log "Unsupported operating system version detected..."
   exit 2
fi
