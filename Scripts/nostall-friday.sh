#!/bin/bash -e

#
# Original Author : Unknown
# Current Author  : Ian Brodowski
# Last Update     : Friday, February 5, 2016
#
# Change History  :
#   * 20160205    : Check bin/* files under Reflektion to ensure that "reflektion" has been replaced with 'current_user_shortname'
#                 :   Exit if it's not the case and prompt to run install_dependencies.sh first
#                 : pip dependency "requests" must be at version 1.1.0
#                 : Moved global variables to the top of the script before any listed functions
#                 : Added new $HOMEDIR variable to find currently logged-in user's home directory
#                 : Removed py-pip and virtualenv as installation within in this script and moved over to install_dependencies.sh
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
#   * 20160125    : Modified the way virtualenv --system-site-packages command is executed; using "sudo -H -u $SUDO_USER" rather than $RunAsUser (i.e., RunAsUser=$(whoami))
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
# OS X 10.10.5 or later
# Install Xcode and Xcode command-line tools; open to accept license and install tools
# Install MacPorts 2.3.4 for OS X 10.10.x (Yosemite)
# Install Homebrew
# Install MySQL 5.5.46 x86_64 for OS X 10.9 (Mavericks)
# Install python27 via MacPorts 2.3.4

# Set global vars
OS_Version=$(sw_vers -productVersion)
HOMEDIR=$(dscl . -read /Users/"$loggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')

log() {

  RunAsUser=$(whoami)

  mkdir -p "$HOMEDIR"/Documents/DevEnv
  touch "$HOMEDIR"/Documents/DevEnv/config.log
  LOGNAME="$HOMEDIR"/Documents/DevEnv/config.log

  echo $1
  echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $LOGNAME

}

main() {

  echo "Running main functions..."
  log "Running main functions..."


  # Set local vars
  local WEBOLOGY, BIN, CLIPIT
  WEBOLOGY="$HOMEDIR"/work/Webology
  BIN=$WEBOLOGY/Website/Reflektion/bin
  CLIPIT=$WEBOLOGY/Website/Reflektion/ClipIt
  log "Setting local varibles for main functions..."

  # Install dependencies using MacPorts
  port install boost
  port install curl # unsure if this is required since there's a system level version available
  port install jpeg
  port install libevent
  port install libpng
  port install lcms
  port install nodejs
  port install npm
  echo "Installing boost, curl, jpeg, libevent, libpng, lcms, nodejs and npm via port..."
  log "Installing boost, curl, jpeg, libevent, libpng, lcms, nodejs and npm via port..."

  # Activate virtual environment
  source $BIN/activate
  echo "Activate virtual environment"
  log "Activate virtual environment"

# Install dependencies using pip
  port install python27
  sudo -H -u $SUDO_USER $BIN/easy_install pip
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade pip
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade setuptools
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade pytz
  sudo -H -u $SUDO_USER $BIN/pip install -r requirements.txt
  echo "Installing mandatory pip dependencies via requirements file..."
  log "Installing mandatory pip dependencies via requirements file..."

  # Install dependencies using Homebrew
  sudo -H -u $SUDO_USER brew install freetype
  sudo -H -u $SUDO_USER brew install thrift
  sudo -H -u $SUDO_USER brew install homebrew/versions/mongodb24
  sudo -H -u $SUDO_USER brew install homebrew/versions/redis26
  echo "Installing freetype, thrift, mongodb24 and redis26 via brew..."
  log "Installing freetype, thrift, mongodb24 and redis26 via brew..."

  # Install phantomjs with npm
  npm -g install phantomjs
  echo "Installing phantomjs via npm..."
  log "Installing phantomjs via npm..."

  # Create symlink for freetype under /opt/local/include/freetype
  ln -s /opt/local/include/freetype2 /opt/local/include/freetype
  echo "Creating symlink for freetype..."
  log "Creating symlink for freetype..."

  LINE1="export PATH=\${PATH}:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin"
  LINE2="export DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH}:/usr/local/mysql/lib/"

  if [ ! -e ~/.bash_profile ]; then
    sudo -u $SUDO_USER touch ~/.bash_profile
  fi
  grep -qsFx "$LINE1" ~/.bash_profile || sudo -u $SUDO_USER printf "%s\n" "$LINE1" >> ~/.bash_profile
  grep -qsFx "$LINE2" ~/.bash_profile || sudo -u $SUDO_USER printf "%s\n" "$LINE2" >> ~/.bash_profile

  pathadd() {
      if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
          PATH="${PATH:+"$PATH:"}$1"
      fi
  }

  pathadd /usr/local/mysql/bin
  pathadd /usr/local/bin
  pathadd /opt/local/bin
  pathadd /opt/local/sbin
  log "Updating paths..."

  # Invoke setup.py after installing all required dependencies
  sudo -H -u $SUDO_USER $BIN/pip install -e $CLIPIT # or $BIN/pip install -e .
  echo "Invoke setup.py after installing all required dependencies"
  log "Invoke setup.py after installing all required dependencies"

  # Decompress mongo dump into /data/db
  mkdir -p /data/db
  chmod 777 /data
  chmod 777 /data/db
  pushd /data/db
  gzip -dc ~/data/Backup/mongo_dump.tgz | tar xvf -
  popd
  echo "Decompress mongo dump into /data/db..."
  log "Decompress mongo dump into /data/db..."

  # Start mongodb services and add users
  $CLIPIT/tools/services/mongo_db/server.py $CLIPIT/development.ini start
  echo 'db.addUser("admin", "admin");' | mongo admin
  echo 'db.auth("admin", "admin");' | mongo admin
  echo 'db.addUser("rfk", "rfk789");' | mongo rfk
  echo "Start mongodb and create users..."
  log "Start mongodb and create users..."

  # Install ElasticSearch
  #cd tools/services/elasticsearch/
  #./install_elasticsearch.sh
  #cd -
  #echo "Install ElasticSearch..."
  #log "Install ElasticSearch..."

  # Import mySQL dump from ~/data/Backup/mysql_dump.sql
  sudo -H -u $SUDO_USER mysql -u root -h localhost < ~/data/Backup/mysql_dump.sql
  echo "Import mySQL dump from ~/data/Backup..."
  log "Import mySQL dump from ~/data/Backup..."

  mkdir -p $CLIPIT/tools/services/var/storage/redis/
  pushd $CLIPIT/tools/services/var/storage/redis/
  gzip -dc ~/data/Backup/redis_dump.tgz | tar xvf -
  popd
  echo "Decompress redis dump from ~/data/Backup..."
  log "Decompress redis dump from ~/data/Backup..."

  # Start required dependencies and/or services
  sudo -u $SUDO_USER $CLIPIT/tools/services/redis/redis.py $CLIPIT/development.ini start
  sudo -u $SUDO_USER $CLIPIT/tools/services/workers/mailer.py $CLIPIT/development.ini start || true
  sudo -u $SUDO_USER $CLIPIT/tools/services/workers/imager.py $CLIPIT/development.ini start || true
  echo "Starting redis, mailer and imager..."
  log "Starting redis, mailer and imager..."

  # Configure thrift
  thrift --gen py -out . thriftService.thrift
  echo "Configuring thrift..."
  log "Configuring thrift..."

  # Updated connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/
  perl -pi -w -e 's/calling_format=DefaultCallingFormat/calling_format=OrdinaryCallingFormat()/g;' ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/connection.py
  echo "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."
  log "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."

}

checkdependencies() {

  echo "Checking mandatory dependencies..."
  log "Checking dependencies..."

  # Set local vars
  local WEB
  WEB=~/work/Webology
  log "Setting local variables for dependencies check..."

  # Update directory paths for all files in ~/work/Webology/Website/Reflektion/bin
  log "Update directory paths in files located in bin..."
  Readline=$(head -1 ~/work/Webology/Website/Reflektion/bin/asadmin)
  if [ $Readline == "#!/Users/reflektion/work/Webology/Website/Reflektion/bin/python" ]; then
    echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" has not been updated, prompting user..."
    echo "Please run the install-dependencies.sh script before running this script..."
  else
    echo "The directory paths for all files in \"~/work/Webology/Website/Reflektion/bin\" have already been updated."
    log "The directory paths for all files in bin have already been updated."
  fi

  # Check for Xcode and Command Line Tools installation
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
  if [ -e $xcodeapp ]; then
      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
        echo "Xcode and Command Line Tools are installed."
        log "Xcode is installed."
      fi
  else
      echo "Xcode and Command Line Tools are not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      exit 1
      log "Xcode is not installed, prompting user..."
  fi

  # Check for mySQL 5.5.46 installation
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  if [ -f $mysqlbinary ]; then
      mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
      if [ $mySQLInstalled == "5.5.46" ]; then
        echo "mySQL 5.5.46 is installed."
        log "mySQL 5.5.46 is installed."
      fi
  else
      echo "mySQL 5.5.46 is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      exit 2
      log "mySQL 5.5.46 is not installed, prompting user..."
  fi

  # Check for MacPorts installation
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
    echo "Please run the install-dependencies.sh script before running this script..."
    exit 3
      log "MacPorts 2.3.4 is not installed, prompting user..."
  fi

  # Check for Homebrew installation
  log "Checking Homebrew installation..."
  brewbinary="/usr/local/bin/brew"
  if [ -f $brewbinary ]; then
    echo "Homebrew is installed, checking version..."
      HomebrewInstalled=$(brew --version | awk '{print $2}')
      if [ $HomebrewInstalled == "0.9.5" ]; then
          echo "Homebrew 0.9.5 is installed."
          log "Homebrew 0.9.5 is installed."
      fi
  else
    echo "Homebrew 0.9.5 is not installed, prompting user..."
    echo "Please run the install-dependencies.sh script before running this script..."
    log "Homebrew 0.9.5 is not installed, prompting user..."
    exit 4
  fi

  # Check for Java Runtime Environment installation
  log "Checking Java Runtime Environment installation…"
  jrebinary="/usr/bin/java"
    if [ -f $jrebinary ]; then
      jreinstalled=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
      if [ $jreinstalled == "1.8.0_73" ]; then
        echo "Java Runtime Environment 1.8.0_73 is installed."
        log "Java Runtime Environment 1.8.0_73 is installed."
      fi
    else
      echo "Java Runtime Environment is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Environment is not installed, prompting user..."
      exit 5
    fi

  # Check for Java Development Kit installation
  log "Checking Java Development Kit installation…"
  jdkbinary="/usr/bin/javac"
    if [ -f $jfkbinary ]; then
      jreinstalled=$(javac -version 2>&1 | awk '{print $2}')
      if [ $jreinstalled == "1.8.0_73" ]; then
        echo "Java Development Kit 1.8.0_73 is installed."
        log "Java Development Kit 1.8.0_73 is installed."
      fi
    else
      echo "Java Runtime Development Kit is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Development Kit is not installed, prompting user..."
      exit 6
    fi

}

if [ $UID != 0 ]; then
  echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == "10.10.5" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.3" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.2" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   checkdependencies
   main
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   log "Unsupported operating system version detected..."
   exit 2
fi
