#!/bin/bash

#
# Original Author : Ian Brodowski
# Last Update     : Monday, April 4, 2016
#
# Change History  :
#   * 20160404    : Added vagrant ssh --c commands
#                 : 
#                 : 
#
#   * 20160401    : Script inception
#                 : 
#                 : 
#

# Set global vars
OS_Version=$(sw_vers -productVersion)
LoggedInUser="`python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");'`"
	# If $LoggedInUser = _mbsetupuser, then use who to query the current user
	if [[ "$LoggedInUser" = "MBSetupUser" || "$LoggedInUser" = "_mbsetupuser" ]]; then
	    LoggedInUser=$(who -q | head -1 | cut -d ' ' -f2)
	fi
HOMEDIR=$(dscl . -read /Users/"$LoggedInUser" NFSHomeDirectory | awk -F':' 'END{gsub(/^[ \t]+/,"",$NF); printf "%s", $NF }')
WEBOLOGY="$HOMEDIR"/work/Webology
BIN=$WEBOLOGY/Website/Reflektion/bin
CLIPIT=$WEBOLOGY/Website/Reflektion/ClipIt
RFK="/Library/RFK"

main() {

	echo "Installing Homebrew..."
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	echo "Update Homebrew..."
	brew upgrade

	echo "Install cask and ansible..."
	brew install cask ansible

	echo "Install vagrant and virtualbox..."
	brew cask install vagrant virtualbox

	echo "Create local Webology diretory..."
	mkdir -p "$HOMEDIR"/work/Webology/

	echo "Clone the Webology respository..."
	git clone https://github.com/Reflektion/Webology "$HOMEDIR"/work/Webology
	pushd $WEBOLOGY
	git checkout develop && git pull
	#echo "Correcting config.vm.synced_folder variable..."
	#perl -pi -w -e 's/"\/srv\/Webology"/"\/home\/rfkadmin\/Webology"/g;' Vagrantfile
	popd

	echo "Set ATLAS_TOKEN..."
	export ATLAS_TOKEN="zzsyW0nnUYNrdA.atlasv1.tEBaintrxK78kn45pQbC7XzuS4BoE3F8Kda7ZoyVZzit3GMXsGPy0Tp5qciXZYSpm2o"

	echo "Starting up vagrant... this may take several minutes."
	pushd $WEBOLOGY
	vagrant up

	#echo "Connecting to vagrant..."
	#vagrant ssh

	echo "Activiating virtualenv..."
	vagrant ssh --c "source /srv/venv/bin/activate"

	#echo "Restarting gunicorn..."
	#vagrant ssh --c "echo vagrant | sudo -S systemctl restart gunicorn"

	echo "Getting gunicorn status..."
	vagrant ssh --c "echo vagrant | sudo -S systemctl status gunicorn"

	echo "Testing connectivity to localhost:6543..."
	vagrant ssh --c "echo vagrant | sudo -S curl localhost:6543/server/status_check"
	
	echo "Show forwarded ports from guest to host..."
	grep forwarded_port Vagrantfile

}

if [ $UID == 0 ]; then
  echo "Please do not run this script using sudo."
  exit 1
fi

if [[ ${OS_Version} == "10.10.5" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   main
elif [[ ${OS_Version} == "10.11.2" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   main
elif [[ ${OS_Version} == "10.11.3" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   main
elif [[ ${OS_Version} == "10.11.4" ]]; then
   echo "Detected valid OS X version, ${OS_Version}, continuing..."
   main
else
   echo "Detected invalid OS X version, ${OS_Version}, exiting..."
   exit 2
fi
