#!/bin/bash

CURRENTDIR=`pwd`
echo $CURRENTDIR
"$CURRENTDIR"/dockutil --remove 'Maps' --no-restart
sleep 2
"$CURRENTDIR"/dockutil --remove 'Photos' --no-restart
sleep 2
"$CURRENTDIR"/dockutil --remove 'iTunes' --no-restart
sleep 2
"$CURRENTDIR"/dockutil --remove 'iBooks' --no-restart
sleep 2
"$CURRENTDIR"/dockutil --add '/Applications/Google Chrome.app' --after Safari --no-restart
sleep 2
"$CURRENTDIR"/dockutil --add '/Applications/Firefox.app' --after 'Google Chrome' --no-restart
sleep 2
"$CURRENTDIR"/dockutil --add '/Applications/Slack.app' --after Firefox --no-restart
sleep 2
"$CURRENTDIR"/dockutil --add '/Applications/Utilities/Terminal.app' --after 'System Preferences'
exit
