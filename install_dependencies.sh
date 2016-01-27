#!/bin/bash

#
# Author		  : Ian Brodowski
# Script Name     : dev_dependencies.sh
# Script Purpose  :	Installs all dependencies as required by install.sh
#
# Last Update     : Tuesday, January 26, 2016
#
# Change History  :
#   * 20160126    : Script inception
#                 : 
#                 : 
#                 :
#

# Pre-requisites: 
# OS X 10.10.5 or later; not OS X 10.11.x
# Install Xcode and Xcode command line tools; open to accept license and install tools
# Install MacPorts 2.3.4 for OS X 10.10.x (Yosemite)
# Install Homebrew
# Install MySQL 5.5.46 x86_64 for OS X 10.9 (Mavericks)


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
  log "Update directory paths in files located in bin..."
  Readline=$(head -1 ~/work/Webology/Website/Reflektion/bin/asadmin)
  if [ $Readline == "#!/Users/reflektion/work/Webology/Website/Reflektion/bin/python" ]; then
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
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
    echo "Xcode and Command Line Tools are installed."
    log "Xcode is installed."
  else
    echo "Xcode and Command Line Tools are not installed, running Xcode wizard..."
    log "Xcode is not installed, attempting to install..."
    # sudo xcode-select --install
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
    # installer -pkg mysql-5.5.46-osx10.8-x86_64.pkg -target /
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
      if [ $OS_Version = '10.10.5' ]; then
         # sudo installer -pkg MacPorts-2.3.4-10.10-Yosemite.pkg -target /
          log "MacPorts 2.3.4 is not installed, attempting install for Yosemite..."
      elif [ $OS_Version = '10.11.2' ]; then
         # sudo installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
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
    # sudo -H -u $SUDO_USER bash -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    log "Homebrew 0.9.5 is not installed, attempting install..."
  fi

}

# Set global vars
OS_Version=$(sw_vers -productVersion)

if [ $UID != 0 ]; then
  echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == 10.11.2 ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   checkdependencies
   #main
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   log "Unsupported operating system version detected..."
   exit 2
fi
