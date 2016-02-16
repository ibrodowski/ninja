#!/bin/bash -e

#
# Original Author : Unknown
# Current Author  : Ian Brodowski
# Last Update     : Tuesday, February 16, 2016
#
# Change History  :
#   * 20160216    : Modify setup.py to include explicit version specifiers for pyramid_beaker==0.8, pyramid_debugtoolbar==1.0.6 and pyramid_tm==0.7
#                 :
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
# Verify installation of Xcode and Xcode command-line tools; open to accept license and install tools
# Verify installation of MacPorts 2.3.4 for OS X 10.10.x (Yosemite) or OS X 10.11.3 (El Capitan)
# Verify installation of Homebrew 0.9.5
# Verify installation of MySQL 5.5.46 x86_64

# Set global vars
OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
WEBOLOGY="$HOMEDIR"/work/Webology
BIN=$WEBOLOGY/Website/Reflektion/bin
CLIPIT=$WEBOLOGY/Website/Reflektion/ClipIt
WEB="$HOMEDIR"/work/Webology
RFK=/Library/RFK

log() {

  mkdir -p "$HOMEDIR"/Documents/DevEnv
  touch "$HOMEDIR"/Documents/DevEnv/config.log
  LOGNAME="$HOMEDIR"/Documents/DevEnv/config.log

  echo $1
  echo $(date "+%Y-%m-%d %H:%M:%S: ") $1 >> $LOGNAME

}

installdependencies() {

  echo "Checking mandatory dependencies..."
  log "Checking mandatory dependencies..."

  # Install Xcode and Command Line Tools
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
    if [ -e $xcodeapp ]; then
      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
        echo "Xcode is installed, opening Xcode for user to accept license and have XCode install its components..."
        log "Xcode is installed, opening Xcode for user to accept license and have XCode install its components..."
        open -W $xcodeapp
        echo "Installing Xcode Command Line Tools..."
        pushd $RFK/
          if [ $OS_Version == "10.10.5" ]; then
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.10\).pkg -target /
              echo "Installing Command Line Tools for Yosemite..."
              log "Installing Command Line Tools for Yosemite..."
          elif [ $OS_Version == "10.11.2" ]; then
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
          elif [ $OS_Version == "10.11.3" ]; then
              installer -pkg Command\ Line\ Tools\ \(OS\ X\ 10.11\).pkg -target /
              echo "Installing Command Line Tools for El Capitan..."
              log "Installing Command Line Tools for El Capitan..."
          fi
        popd
      fi
  else
    echo "Xcode is not installed, please install Xcode..."
    log "Xcode is not installed, please install Xcode..."
    exit 3
  fi

  # Install mySQL 5.5.46
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  if [ -f $mysqlbinary ]; then
      echo "mySQL is installed, checking version..."
      log "mySQL is installed, checking version..."
      mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
      if [ $mySQLInstalled = "5.5.46" ]; then
        echo "mySQL 5.5.46 is installed."
        log "mySQL 5.5.46 is installed."
      fi
  else
    echo "mySQL 5.5.46 is not installed, running installation..."
    pushd $RFK/
    installer -pkg mysql-5.5.46-osx10.8-x86_64.pkg -target /
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
    if [ -f $jdkbinary ]; then
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
    
  # Update setup.py to include explicit versions specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm
  echo "Updating setup.py to include explicit version specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm"
  log "Updating setup.py to include explicit version specifiers for pyramid_beaker, pyramid_debugtoolbar and pyramid_tm"
  perl -pi -w -e 's/pyramid_beaker/pyramid_beaker==0.8/g;' "$HOMEDIR"/work/Webology/Website/Reflektion/ClipIt/setup.py
  perl -pi -w -e 's/pyramid_debugtoolbar/pyramid_debugtoolbar==1.0.6/g;' "$HOMEDIR"/work/Webology/Website/Reflektion/ClipIt/setup.py
  perl -pi -w -e 's/pyramid_tm/pyramid_tm==0.7/g;' "$HOMEDIR"/work/Webology/Website/Reflektion/ClipIt/setup.py

}

checkdependencies() {

  echo "Checking mandatory dependencies..."
  log "Checking dependencies..."

  # Check for Xcode.app
  log "Checking Xcode installation..."
  XcodeInstalled=$(xcode-select -p)
  xcodeapp="/Applications/Xcode.app"
  if [ -e $xcodeapp ]; then
      if [ $XcodeInstalled == "/Applications/Xcode.app/Contents/Developer" ]; then
        echo "Xcode.app is installed."
        log "Xcode.app is installed."
      fi
  else
      echo "Xcode is not installed, prompting user..."
      echo "Please manually install Xcode.app and the Xcode Command Line Tools before running this script..."
      exit 3
      log "Xcode is not installed, prompting user..."
      log "Please manually install Xcode.app and the Xcode Command Line Tools before running this script..."
  fi

  # Check for mySQL 5.5.46 installation
  #mySQLInstalled=$(mysql --version | awk '{print $5}' | sed 's/,//g')
  log "Checking mySQL installation..."
  mysqlbinary="/usr/local/mysql/bin/mysql"
  if [ -f $mysqlbinary ]; then
      mySQLInstalled=$(mysql --version | awk -F ',' '{print $1}' | awk '{print $NF}')
      if [ $mySQLInstalled = "5.5.46" ]; then
        echo "mySQL 5.5.46 is installed."
        log "mySQL 5.5.46 is installed."
      fi
  else
      echo "mySQL 5.5.46 is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      exit 4
      log "mySQL 5.5.46 is not installed, prompting user..."
  fi

  # Check for MacPorts installation
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
    echo "Please run the install-dependencies.sh script before running this script..."
    exit 5
    log "MacPorts 2.3.4 is not installed, prompting user..."
  fi

  # Check for Homebrew installation
  log "Checking Homebrew installation..."
  brewbinary="/usr/local/bin/brew"
  if [ -f $brewbinary ]; then
    echo "Homebrew is installed, checking version..."
      HomebrewInstalled=$(brew --version | awk '{print $2}')
      if [ $HomebrewInstalled = "0.9.5" ]; then
          echo "Homebrew 0.9.5 is installed."
          log "Homebrew 0.9.5 is installed."
      fi
  else
    echo "Homebrew 0.9.5 is not installed, prompting user..."
    echo "Please run the install-dependencies.sh script before running this script..."
    log "Homebrew 0.9.5 is not installed, prompting user..."
    exit 6
  fi

  # Check for Java Runtime Environment installation
  log "Checking Java Runtime Environment installation…"
  jrebinary="/usr/bin/java"
    if [ -f $jrebinary ]; then
      jreinstalled=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
      if [ $jreinstalled = "1.8.0_73" ]; then
        echo "Java Runtime Environment 1.8.0_73 is installed."
        log "Java Runtime Environment 1.8.0_73 is installed."
      fi
    else
      echo "Java Runtime Environment is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Environment is not installed, prompting user..."
      exit 7
    fi

  # Check for Java Development Kit installation
  log "Checking Java Development Kit installation…"
  jdkbinary="/usr/bin/javac"
    if [ -f $jdkbinary ]; then
      jreinstalled=$(javac -version 2>&1 | awk '{print $2}')
      if [ $jreinstalled = "1.8.0_73" ]; then
        echo "Java Development Kit 1.8.0_73 is installed."
        log "Java Development Kit 1.8.0_73 is installed."
      fi
    else
      echo "Java Runtime Development Kit is not installed, prompting user..."
      echo "Please run the install-dependencies.sh script before running this script..."
      log "Java Runtime Development Kit is not installed, prompting user..."
      exit 8
    fi

}

main() {

  echo "Running main functions..."
  log "Running main functions..."

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
  #port install python27
  sudo -H -u $SUDO_USER $BIN/easy_install pip
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade pip
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade setuptools
  sudo -H -u $SUDO_USER $BIN/pip install --upgrade pytz
  sudo -H -u $SUDO_USER bash -c 'env ARCHFLAGS="-arch x86_64" pip install pycurl==7.19'
  sudo -H -u $SUDO_USER bash -c 'CFLAGS="-I /opt/local/include -L /opt/local/lib" pip install gevent==0.13.8'
  sudo -H -u $SUDO_USER $BIN/pip install http://effbot.org/media/downloads/Imaging-1.1.7.tar.gz
  sudo -H -u $SUDO_USER $BIN/pip install https://launchpad.net/python-weather-api/trunk/0.3.8/+download/pywapi-0.3.8.tar.gz
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
  gzip -dc "$HOMEDIR"/data/Backup/mongo_dump.tgz | tar xvf -
  popd
  echo "Decompress mongo dump into /data/db..."
  log "Decompress mongo dump into /data/db..."

  # Start mongodb services and add users
  $CLIPIT/tools/services/mongo_db/server.py $CLIPIT/development.ini start
  echo "use admin" > mongousers.js
  echo "db.addUser(\"admin\", \"admin\")" >> mongousers.js
  echo "db.auth(\"admin\", \"admin\")" >> mongousers.js
  echo "use rfk" >> mongousers.js
  echo "db.addUser(\"rfk\", \"rfk789\")" >> mongousers.js
  mongo < mongousers.js
  rm mongousers.js
  echo "Start mongodb and create users..."
  log "Start mongodb and create users..."

  # Install ElasticSearch
  pushd $CLIPIT/tools/services/es_helper/
  ./install_elasticsearch.sh
  echo "Install ElasticSearch..."
  log "Install ElasticSearch..."
  popd

  # Import mySQL dump from ~/data/Backup/mysql_dump.sql
  /usr/local/mysql/support-files/mysql.server start
  sudo -H -u $SUDO_USER mysql -u root -h localhost < "$HOMEDIR"/data/Backup/mysql_dump.sql
  echo "Import mySQL dump from ~/data/Backup..."
  log "Import mySQL dump from ~/data/Backup..."

  mkdir -p $CLIPIT/tools/services/var/storage/redis/
  pushd $CLIPIT/tools/services/var/storage/redis/
  gzip -dc "$HOMEDIR"/data/Backup/redis_dump.tgz | tar xvf -
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

  # Configure thrift widget benchmark
  pushd $CLIPIT/tools/services/customers/widget_benchmark
  thrift --gen py -out . WidgetBenchmark.thrift
  echo "Configuring thrift widget benchmark..."
  popd

  # Update connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/
  perl -pi -w -e 's/calling_format=DefaultCallingFormat/calling_format=OrdinaryCallingFormat()/g;' ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/connection.py
  echo "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."
  log "Updating connection.py in ~/work/Webology/Website/Reflektion/lib/python2.7/site-packages/boto/s3/..."

}

if [ $UID != 0 ]; then
  echo "Please run this script using sudo."
  log "Script was not executed via sudo."
  exit 1
fi

if [[ ${OS_Version} == "10.10.5" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.2" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
elif [[ ${OS_Version} == "10.11.3" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   log "Supported operating system version detected..."
   installdependencies
   checkdependencies
   main
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   log "Unsupported operating system version detected..."
   exit 2
fi
