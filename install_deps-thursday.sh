#!/bin/bash

#
# Author		      : Ian Brodowski
# Script Name     : install_dependencies.sh
# Script Purpose  :	Installs all dependencies as required by install.sh
#                 :   Such as the following:
#                 :   Xcode 7.2, Xcode command-line tools for Yosemite or El Capitan, mySQL 5.5.46, MacPorts 2.3.4, Homebrew 0.9.5 and Python 2.7 (via port)
#
# Last Update     : Thursday, February 4, 2016
#
# Change History  :
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

log() {

  RunAsUser=$(whoami)

  mkdir -p ~/Documents/DevEnv
  touch ~/Documents/DevEnv/dependencies.log
  LOGNAME=~/Documents/DevEnv/dependencies.log

  echo $1
  echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $LOGNAME

}

checkdependencies() {

  log "Checking dependencies..."

  # Set local vars
  local WEB
  WEB=~/work/Webology
  log "Setting local variables for dependencies check..."

  echo "Checking mandatory dependencies..."

  # Update directory paths for all files in ~/work/Webology/Website/Reflektion/bin
  #log "Update directory paths in files located in bin..."
  #Readline=$(head -1 ~/work/Webology/Website/Reflektion/bin/asadmin)
  #if [ $Readline == "#!/Users/reflektion/work/Webology/Website/Reflektion/bin/python" ]; then
  #  echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" has not been updated, applying changes..."
  #  pushd $WEB/Website/Reflektion/
  #  perl -pi -w -e 's/reflektion/$ENV{'LOGNAME'}/g;' bin/*
  #  popd
  #  log "Directory paths update completed."
  #else
  # echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" have already been updated."
  # log "The directory paths for all files in bin have already been updated."
  #fi

  # Install Xcode and Command Line Tools
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
    if [ -e $xcodeapp ]; then
      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
        echo "Xcode is installed."
        log "Xcode is installed."
        xcrun cc
        echo "Installing Xcode Command Line Tools..."
        pushd $WEB/Website/Reflektion/ClipIt/tools/software/
          if [ $OS_Version == '10.10.5' ]; then
              sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /
              echo "Installing Command Line Tools for Yosemite..."
              log "Installing Command Line Tools for Yosemite..."
          elif [ $OS_Version == '10.11.2' ]; then
              sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
          elif [ $OS_Version == '10.11.3' ]; then
              sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
          fi
        popd
  else
    echo "Xcode and Command Line Tools are not installed, running Xcode wizard..."
    log "Xcode is not installed, attempting to install..."
    sudo xcode-select --install || true
      pushd $WEB/Website/Reflektion/ClipIt/tools/software/
        if [ $OS_Version == '10.10.5' ]; then
            sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /
            log "Installing Command Line Tools for Yosemite..."
        elif [ $OS_Version == '10.11.2' ]; then
            sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
            log "Installing Command Line Tools for El Capitan..."
        elif [ $OS_Version == '10.11.3' ]; then
            sudo -H -u $SUDO_USER installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
            log "Installing Command Line Tools for El Capitan..."
        fi
        popd
  fi

  # Install mySQL 5.5.46
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
  if [ $mySQLInstalled == "5.5.46" ]; then
    echo "mySQL 5.5.46 is installed."
    log "mySQL 5.5.46 is installed."
  else
    echo "mySQL 5.5.46 is not installed, running installation..."
    pushd $WEB/Website/Reflektion/ClipIt/tools/software/
    sudo -H -u $SUDO_USER installer -pkg mysql-5.5.46-osx10.9-x86_64.pkg -target /
    popd
    log "mySQL 5.5.46 is not installed, attempting to install..."
  fi

  # Install MacPorts
  log "Checking MacPorts installation..."
  portbinary="/opt/local/bin/port"
  if [ -f $portbinary ]; then
    echo "Port is installed, checking version..."
      PortInstalled=$(port version | awk '{print $2}')
      if [ $PortInstalled ==  "2.3.4" ]; then
        echo "MacPorts 2.3.4 is installed."
        log "MacPorts 2.3.4 is installed."
      fi
  else
    echo "MacPorts 2.3.4 is not installed, running installation..."
      pushd $WEB/Website/Reflektion/ClipIt/tools/software/
      if [ $OS_Version == '10.10.5' ]; then
          sudo -H -u $SUDO_USER installer -pkg MacPorts-2.3.4-10.10-Yosemite.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for Yosemite..."
      elif [ $OS_Version == '10.11.2' ]; then
          sudo -H -u $SUDO_USER installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
      elif [ $OS_Version == '10.11.3' ]; then
          sudo -H -u $SUDO_USER installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
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
    	if [ $HomebrewInstalled == "0.9.5" ]; then
      	  echo "Homebrew 0.9.5 is installed."
          log "Homebrew 0.9.5 is installed"
        fi
  else
    echo "Homebrew 0.9.5 is not installed, running installation..."
    sudo -H -u $SUDO_USER bash -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    log "Homebrew 0.9.5 is not installed, attempting install..."
  fi

  # Install py-pip and python27 within ~/work/Webology/Website/Reflektion/bin
  pushd $WEB/Website/Reflektion/bin/
  echo "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
  log "Changing working directory to ~/work/Webology/Website/Reflektion/bin..."
  port install py-pip
  port install python27
  echo "Installing py-pip and python27 into ~/work/Webology/Website/Reflektion/bin via port..."
  log "Installing py-pip and python27 into ~/work/Webology/Website/Reflektion/bin via port..."
  popd

}

# Set global vars
OS_Version=$(sw_vers -productVersion)

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
