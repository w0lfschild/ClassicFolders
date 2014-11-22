#!/bin/bash

# -- Information --
# Maintained By : Wolfgang Baird
# Version : 1.0.1
# Updated : Nov / 22 / 2014
# Icons : Apple Inc.

clear; echo -e "\
-- Information --\n\
Maintained By : Wolfgang Baird\n\
Version : 1.0.1\n\
Updated : Nov / 22 / 2014\n\n\n\
This script requires that you enter your password to continue.\n\
You won't see your password as you type it.\n\
Press return once you've finished typing your password."

appsupport_dir="$HOME"/Library/Application\ Support/ycf
sudo -v

# Get trash script
curl -\# -L -o "$appsupport_dir"/trash "https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/trash"
chmod 755 "$appsupport_dir"/trash

# Check for backup
if [[  -e /System/Library/CoreServices/.CoreTypes.bundle.old ]]; then
	if [[ ! -e "$appsupport_dir"/icons ]]; then mkdir -p "$appsupport_dir"/icons; fi
	
	# Backup existing CoreTypes
	#echo -e "Backing up existing CoreTypes to \"/System/Library/CoreServices/.CoreTypes.bundle.old\""
	#sudo cp -r /System/Library/CoreServices/CoreTypes.bundle  /System/Library/CoreServices/.CoreTypes.bundle.old
	
	# Get icons
	if [[ ! -e "$appsupport_dir"/icns.zip ]]; then
		echo -e "Fetching icons"
		curl -\# -L -o "$appsupport_dir"/icns.zip "https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/icons.zip"
		unzip "$appsupport_dir"/icns.zip -d "$appsupport_dir"/icons
	fi
	
	# Moving icons
	echo -e "Moving icons into place"
	sudo cp -rf "$appsupport_dir"/icons /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/
else
	echo -e "Backup Detected!\nWould you like to restore from it now? (y/n): "
	read res_me
	if [[ $res_me = "y" ]]; then
		sudo rm -rf /System/Library/CoreServices/CoreTypes.bundle
		sudo mv /System/Library/CoreServices/.CoreTypes.bundle.old /System/Library/CoreServices/CoreTypes.bundle
	else 
		exit
	fi
fi

# Clear icon caches
sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \;
sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \;
"$appsupport_dir"/trash /Library/Caches/com.apple.iconservices.store

# Prompt for reboot
echo -e "Done!\n\
Now all you need to do is reboot for changes to take effect.\n\
Would you like to reboot now? (y/n): "
read rb_now
if [[ $rb_now = "y" ]]; then sudo reboot; fi