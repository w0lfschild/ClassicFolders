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

plist="$HOME"/Library/Preferences/org.w0lf.cy.plist
scriptDirectory=$(cd "${0%/*}" && echo $PWD)
appsupport_dir="$HOME"/Library/Application\ Support/ycf
dl_url="https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/icons.zip"
#old_icons="$scriptDirectory"/icons
sudo -v

# Check for backup
if [[ ! -e /System/Library/CoreServices/.CoreTypes.bundle.old ]]; then
	if [[ ! -e "$appsupport_dir" ]]; then mkdir -p "$appsupport_dir"; fi
	
	# Backup existing CoreTypes
	echo -e "Backing up existing CoreTypes to \"/System/Library/CoreServices/.CoreTypes.bundle.old\""
	sudo cp -r /System/Library/CoreServices/CoreTypes.bundle  /System/Library/CoreServices/.CoreTypes.bundle.old
	
	# Get icons
	echo -e "Fetching icons"
	curl -\# -L -o "$appsupport_dir"/icns.zip "$dl_url"
	unzip "$appsupport_dir"/icns.zip
	rm "$appsupport_dir"/incs.zip
	
	# Moving icons
	echo -e "Moving icons into place"
	sudo cp -rf "$appsupport_dir"/icons /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/
	#sudo cp -rf "$old_icons"/ /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/
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
sudo "$scriptDirectory"/trash /Library/Caches/com.apple.iconservices.store
#sudo mv /Library/Caches/com.apple.iconservices.store com.apple.ic

# Prompt for reboot
echo -e "Done!\n\
Now all you need to do is reboot for changes to take effect.\n\
Would you like to reboot now? (y/n): "
read rb_now
if [[ $rb_now = "y" ]]; then sudo reboot; fi