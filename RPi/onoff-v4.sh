#!/bin/bash

#
# Original Author : Various People
# Current Author  : Ian Brodowski (ibrodowski on GitHub https://github.com/ibrodowski/ninja/tree/master/RPi)
# Last Update     : Sunday, April 30, 2017
#
# Description     : This script installs required apt-get packages and files to enable
#		    the use of a PC power or reset (momentary) switch to safely shutdown
#		    the Raspberry Pi.
#
#		    When the switch is used to safely shutdown the Raspberry Pi, it will continue to draw a few hundred milliamps.
#					
#		    This script does not require an active internet connection for the accompanying files (shutdown.py & 
#		    pi_shutdown.  However, the mandatory python binaries require an active internet connection;
#		    please review this code in its entirety prior to execution.
#
# Warranty	  : This script and its contents are provided AS IS without warranty of any kind.
# Disclaimer
#		    Ian Brodowski (@ibrodowski on GitHub) disclaims all implied warranties including, without limitation
#		    any implied warranties of merchantability or of fitness for a particular purpose.
#
#		    The entire risk arising out of the use or performance of this script and documentation remains solely with you.
#
# Change History  :
#   * 20170430    : Debugging and random grammatical corrections
#                 : Added warranty disclaimer
#
#   * 20170425    : Debugging and random grammatical corrections
#
#   * 20170424    : Debugging and random grammatical corrections
#

#
# Setup Global Variables
#
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

#
# Main Installation Routine
#
install() {

	printf "Performing ${GREEN}apt-get${NC} ${BLUE}update${NC}...\n"
	apt-get -y update

	#printf "Installing ${GREEN}gcc${NC}, ${GREEN}python-dev${NC}, ${GREEN}python3-dev${NC}, and ${GREEN}python-pip${NC} using ${BLUE}apt-get${NC}...\n"
	printf "Installing ${GREEN}python-rpi.gpio${NC} and ${GREEN}python3-rpi.gpio${NC} using ${BLUE}apt-get${NC}...\n"
	apt-get install --yes python-rpi.gpio python3-rpi.gpio

	#printf "Installing ${GREEN}RPi.GPIO v0.6.3${NC} using ${BLUE}pip${NC}...\n"
	#pip install RPi.GPIO>=0.6.3

	printf "Creating ${GREEN}scripts${NC} directory under ${BLUE}/home/pi/${NC}...\n"
	mkdir /home/pi/scripts

	printf "Creating ${GREEN}shutdown.py${NC} python script under ${BLUE}/home/pi/scripts/${NC}...\n"
	touch /home/pi/scripts/shutdown.py

	printf "Formatting ${GREEN}shutdown.py${NC} with ${BLUE}required${NC} content...\n"
	echo "#!/usr/bin/python" > /home/pi/scripts/shutdown.py
	echo "import RPi.GPIO as GPIO" >> /home/pi/scripts/shutdown.py
	echo "import time" >> /home/pi/scripts/shutdown.py
	echo "import subprocess" >> /home/pi/scripts/shutdown.py
	echo "" >> /home/pi/scripts/shutdown.py
	echo "GPIO.setmode(GPIO.BOARD)" >> /home/pi/scripts/shutdown.py
	echo "currentButtonState = True" >> /home/pi/scripts/shutdown.py
	echo "" >> /home/pi/scripts/shutdown.py
	echo "while True:" >> /home/pi/scripts/shutdown.py
	echo "buttonState = GPIO.input(5)" >> /home/pi/scripts/shutdown.py
	echo "" >> /home/pi/scripts/shutdown.py
	echo "if buttonState != currentButtonState and buttonState == False:" >> /home/$
	echo 'subprocess.call("shutdown -h now", shell=True' >> /home/pi/scripts/shutdown.py
	echo "stdout=subprocess.PIPE, stderr=subprocess.PIPE)" >> /home/pi/scripts/shutdown.py
	echo "currentButtonState = buttonState" >> /home/pi/scripts/shutdown.py
	echo "" >> /home/pi/scripts/shutdown.py
	echo "time.sleep(.1)" >> /home/pi/scripts/shutdown.py

	printf "Creating ${GREEN}init.d${NC} service script ${RED}pi_shutdown${NC} under ${BLUE}/etc/init.d${NC}...\n"
	touch /etc/init.d/pi_shutdown

	printf "Formatting ${GREEN}pi_shutdown${NC} service script with ${BLUE}required${NC} content...\n"
	echo "#!/bin/sh" > /etc/init.d/pi_shutdown
	echo "### BEGIN INIT INFO" >> /etc/init.d/pi_shutdown
	echo "# Provides: pi_shutdown" >> /etc/init.d/pi_shutdown
	echo "# Required-Start: $remote_fs $syslog" >> /etc/init.d/pi_shutdown
	echo "# Required-Stop: $remote_fs $syslog" >> /etc/init.d/pi_shutdown
	echo "# Default-Start: S" >> /etc/init.d/pi_shutdown
	echo "# Default-Stop: " >> /etc/init.d/pi_shutdown
	echo "# Description: Python script listens for state change on GPIO3/PIN5 and then runs shutdown command" >> /etc/init.d/pi_shutdown
	echo "### END INIT INFO" >> /etc/init.d/pi_shutdown
	echo "" >> /etc/init.d/pi_shutdown
	echo "sudo python /home/pi/scripts/shutdown.py &" >> /etc/init.d/pi_shutdown

	printf "Enabling ${GREEN}execution bit${NC} for ${BLUE}pi_shutdown${NC} service script...\n"
	chmod +x /etc/init.d/pi_shutdown

	printf "Installing ${GREEN}pi_shutdown${NC} service script to run at ${RED}boot-time${NC} using ${BLUE}update-rc.d${NC}...\n"
	update-rc.d pi_shutdown defaults

	printf "To ${GREEN}enable${NC} the ${RED}changes{NC} a ${BLUE}restart${NC} is recommended...\n"
	read -p -r "Would you like to restart now? <y/N> " prompt
	if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
	then
	  shutdown -r now
	else
	  printf "You've ${GREEN}chosen${NC} not to ${RED}reboot{NC} at this ${BLUE}time${NC}, exiting installation script...\n"
	  exit 0
	fi

}

printf "This script enables the ability to use a momentary switch to safely shutdown and\n"
printf "turn on a Raspberry Pi which mitigates the possibility of data corruption.\n"
printf " \n"
printf "This script performs updates and installations using sudo, which modifies\n"
printf "system configuration and could possibly render your current installation\n"
printf "useless."
printf " \n"
printf " \n"
read -p -r "Would you like to continue? <y/N> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  install()
else
  printf "You've ${GREEN}chosen${NC} not to perform the ${RED}installation{NC} at this ${BLUE}time${NC}, exiting installation script...\n"
  exit 0
fi

if [ $EUID != 0 ]; then
  #echo "Please run this script using sudo."
  exit 1
fi
