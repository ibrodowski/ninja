#!/bin/bash -e

#
# Original Author : Unknown
# Current Author  : Ian Brodowski
# Last Update     : Wednesday, February 3, 2016
#
# Change History  :
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

log() {

  RunAsUser=$(whoami)

  mkdir -p ~/Documents/DevEnv
  touch ~/Documents/DevEnv/config.log
  LOGNAME=~/Documents/DevEnv/config.log

  echo $1
  echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $LOGNAME

}

main() {

  log "Running main functions..."

  # Set local vars
  #local WEBOLOGY
  WEBOLOGY=~/work/Webology
  BIN=$WEBOLOGY/Website/Reflektion/bin
  CLIPIT=$WEBOLOGY/Website/Reflektion/ClipIt
  log "Setting local varibles for main functions..."

  echo "Running main functions..."

  # Install py-pip
  port install py-pip
  log "Installing py-pip via port..."

  # Install virtualenv and set system-site-packages to ~/work/Webology/Website/Reflektion
  curl -O https://pypi.python.org/packages/source/v/virtualenv/virtualenv-1.10.1.tar.gz
  tar xvfz virtualenv-1.10.1.tar.gz
  cd virtualenv-1.10.1
  python setup.py install
  cd -
  sudo -H -u $SUDO_USER bash -c 'UserName=$(whoami) || /Users/$UserName/work/Webology/Website/Reflektion/bin/virtualenv --system-site-packages /Users/$UserName/work/Website/Reflektion'
  log "Installing virtual-env and setting system-site-packages..."

  # Install dependencies using MacPorts
  port install boost
  port install curl # unsure if this is required since there's a system level version available
  port install jpeg
  port install libevent
  port install libpng
  port install lcms
  port install nodejs
  port install npm
  log "Installing boost, curl, jpeg, libevent, libpng, lcms, nodejs, npm  and python27 via port..."

  # Activate virtual environment
  source $BIN/activate
  log "Activate virtual environment"

# Install dependencies using pip
  pushd $BIN
  port install python27
  sudo -H -u $SUDO_USER easy_install pip
  sudo -H -u $SUDO_USER pip --upgrade -r requirements-upgrade.txt
  sudo -H -u $SUDO_USER pip install -r requirements.txt
  popd
  #sudo -H -u $SUDO_USER $BIN/pip install cython
  #sudo -H -u $SUDO_USER $BIN/pip install redis
  #sudo -H -u $SUDO_USER $BIN/pip install pytz
  #sudo -H -u $SUDO_USER $BIN/pip install --upgrade pytz  
  #sudo -H -u $SUDO_USER $BIN/pip install scipy==0.14.0
  #sudo -H -u $SUDO_USER $BIN/pip install scikit-learn==0.15.0
  #sudo -H -u $SUDO_USER $BIN/pip install git+git://github.com/bbangert/beaker_extensions.git
  #sudo -H -u $SUDO_USER $BIN/pip install http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz 
  #sudo -H -u $SUDO_USER $BIN/pip install scipy==0.14.0
  #sudo -H -u $SUDO_USER $BIN/pip install numpy==1.8.1
  #sudo -H -u $SUDO_USER $BIN/pip install jsonschema==2.4.0
  #sudo -H -u $SUDO_USER $BIN/pip install distribute
  #sudo -H -u $SUDO_USER $BIN/pip install funcsigs
  #sudo -H -u $SUDO_USER $BIN/pip install lxml==2.3.5
  #sudo -H -u $SUDO_USER $BIN/pip install pycurl==7.19
  #sudo -H -u $SUDO_USER $BIN/pip install gensim
  #sudo -H -u $SUDO_USER $BIN/pip install pyramid==1.3
  #sudo -H -u $SUDO_USER $BIN/pip install pbr
  #sudo -H -u $SUDO_USER $BIN/pip install mock
  #sudo -H -u $SUDO_USER $BIN/pip install matplotlib==1.4.3
  #sudo -H -u $SUDO_USER $BIN/pip install user-agents==1.0.1
  #sudo -H -u $SUDO_USER $BIN/pip install ua-parser==0.4.1
  #sudo -H -u $SUDO_USER $BIN/pip install newrelic
  #sudo -H -u $SUDO_USER $BIN/pip install pyes==0.20.0
  #sudo -H -u $SUDO_USER $BIN/pip install planout==0.5
  #sudo -H -u $SUDO_USER $BIN/pip install geoip2
  #sudo -H -u $SUDO_USER $BIN/pip install gevent==0.13.8
  log "Installing cython, redis, pytz upgrade, scipy, scikit-learn, beaker_extensions, ua-parser, PIL, scipy, numpy, jsonschema, distribute, funcsigs, lxml, pycurl, gensim, pyramid, setuptools upgrade, pbr, mock, matplotlib, user-agents, ua-parser, newrelic, pyes, planout, geoip2, gevent..."

  # Install dependencies using Homebrew
  sudo -H -u $SUDO_USER brew install freetype
  sudo -H -u $SUDO_USER brew install thrift
  sudo -H -u $SUDO_USER brew install homebrew/versions/mongodb24
  sudo -H -u $SUDO_USER brew install homebrew/versions/redis26
  log "Installing freetype, thrift, mongodb24 and redis26 via brew..."

  # Install phantomjs with npm
  npm -g install phantomjs
  log "Installing phantomjs via npm..."

  # Create symlink for freetype under /opt/local/include/freetype
  ln -s /opt/local/include/freetype2 /opt/local/include/freetype
  log "Creating symlink for freetype..."

  #LINE1="export PATH=\${PATH}:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin"
  #LINE2="export DYLD_LIBRARY_PATH=\${DYLD_LIBRARY_PATH}:/usr/local/mysql/lib/"

  #if [ ! -e ~/.bash_profile ]; then
  #  sudo -u $SUDO_USER touch ~/.bash_profile
  #fi
  #grep -qsFx "$LINE1" ~/.bash_profile || sudo -u $SUDO_USER printf "%s\n" "$LINE1" >> ~/.bash_profile
  #grep -qsFx "$LINE2" ~/.bash_profile || sudo -u $SUDO_USER printf "%s\n" "$LINE2" >> ~/.bash_profile

  #pathadd() {
  #    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
  #        PATH="${PATH:+"$PATH:"}$1"
  #    fi
  #}

  #pathadd /usr/local/mysql/bin
  #pathadd /opt/local/bin
  #pathadd /opt/local/sbin
  #log "Updating paths..."

  # Invoke setup.py after installing all required dependencies
  sudo -H -u $SUDO_USER $BIN/pip install -e $CLIPIT # or $BIN/pip install -e .
  log "Invoke setup.py after installing all required dependencies"

  # Decompress mongo dump into /data/db
  mkdir -p /data/db
  chmod 777 /data
  chmod 777 /data/db
  pushd /data/db
  gzip -dc ~/data/Backup/mongo_dump.tgz | tar xvf -
  popd
  log "Decompress mongo dump into /data/db..."

  # Start mongodb services and add users
  $CLIPIT/tools/services/mongo_db/server.py $CLIPIT/development.ini start
  echo 'db.addUser("admin", "admin");' | mongo admin
  echo 'db.addUser("rfk", "rfk789");' | mongo rfk
  #mongo <<EOF
  #use admin
  #db.addUser('admin', 'admin')
  #db.auth('admin', 'admin')
  #use rfk
  #db.addUser('rfk', 'rfk789')
  #exit
  #EOF
  log "Start mongodb and create users..."

  # Install ElasticSearch
  cd tools/services/elasticsearch/
  ./install_elasticsearch.sh
  cd -
  log "Install ElasticSearch..."

  # Start mysql services
  #/usr/local/mysql/support-files/mysql.server start
  #log "Start mysql server..."

  # Import mySQL dump from ~/data/Backup/mysql_dump.sql
  sudo -H -u $SUDO_USER mysql -u root -h localhost < ~/data/Backup/mysql_dump.sql
  log "Import mySQL dump from ~/data/Backup..."

  mkdir -p $CLIPIT/tools/services/var/storage/redis/
  pushd $CLIPIT/tools/services/var/storage/redis/
  gzip -dc ~/data/Backup/redis_dump.tgz | tar xvf -
  popd
  log "Decompress redis dump from ~/data/Backup..."

  # Start required dependencies and/or services
  sudo -u $SUDO_USER $CLIPIT/tools/services/redis/redis.py $CLIPIT/development.ini start
  sudo -u $SUDO_USER $CLIPIT/tools/services/workers/mailer.py $CLIPIT/development.ini start || true
  sudo -u $SUDO_USER $CLIPIT/tools/services/workers/imager.py $CLIPIT/development.ini start || true
  log "Starting mongodb, redis, mailer and imager..."

  # Configure thrift
  thrift --gen py -out . thriftService.thrift
  log "Configuring thrift..."

  # Updated connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/
  perl -pi -w -e 's/calling_format=DefaultCallingFormat/calling_format=OrdinaryCallingFormat()/g;' ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/connection.py
  log "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."

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
  xcodeapp="/Applications/Xcode.app"
  if [ -f $xcodeapp ]; then
      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
        echo "Xcode and Command Line Tools are installed."
        log "Xcode is installed."
      fi
  else
      echo "Xcode and Command Line Tools are not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      exit 1
      log "Xcode is not installed, prompting user..."
      #sudo xcode-select --install
  fi

  # Install mySQL 5.5.46
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
      #pushd $WEB/Website/Reflektion/ClipIt/tools/software/
      #sudo installer -pkg mysql-5.5.46-osx10.8-x86_64.pkg -target /
      #popd
      log "mySQL 5.5.46 is not installed, prompting user..."
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
    echo "Please run the install-dependencies.sh script before running this script..."
    exit 3
      #pushd $WEB/Website/Reflektion/ClipIt/tools/software/
      #if [ $OS_Version = '10.10.5' ]; then
      #    #sudo installer -pkg MacPorts-2.3.4-10.10-Yosemite.pkg -target /
      #    log "MacPorts 2.3.4 is not installed, attempting install for Yosemite..."
      #elif [ $OS_Version = '10.11.3' ]; then
      #    #sudo installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
      #    log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
      #elif [ $OS_Version = '10.11.2' ]; then
      #    #sudo installer -pkg MacPorts-2.3.4-10.11-ElCapitan.pkg -target /
      #    log "MacPorts 2.3.4 is not installed, attempting install for El Capitan..."
      #fi
      log "MacPorts 2.3.4 is not installed, prompting user..."
      #popd
  fi

  # Install Homebrew
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
    exit 4
    #sudo -H -u $SUDO_USER bash -c 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'
    log "Homebrew 0.9.5 is not installed, prompting user..."
  fi

}

# Set global vars
OS_Version=$(sw_vers -productVersion)

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
