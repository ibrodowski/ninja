#
#!/bin/bash

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -activate -configure -clientopts -setvnclegacy -vnclegacy -no -setreqperm -reqperm no -setmenuextra -menuextra no
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -users 'admin_account_name' -access -on -privs -all 
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -configure -allowAccessFor -specifiedUsers
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent -menu
