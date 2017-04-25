#!/bin/bash
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

printf "Performing ${GREEN}apt-get${NC} ${BLUE}update${NC}...\n"
apt-get -y update

printf "Installing ${GREEN}gcc${NC}, ${GREEN}python-dev${NC}, ${GREEN}python3-dev${NC}, and ${GREEN}python-pip${NC} using ${BLUE}apt-get${NC}...\n"
apt-get install --yes python-dev python3-dev gcc python-pip

printf "Installing ${GREEN}RPi.GPIO v0.6.3${NC} using ${BLUE}pip${NC}...\n"
pip install RPi.GPIO>=0.6.3

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
echo "# Short-Description: Perform shutdown when GPIO3/PIN5 is shorted with GND" >> /etc/init.d/pi_shutdown
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

if [ $UID != 0 ]; then
  #echo "Please run this script using sudo."
  exit 1
fi
