#!/bin/bash

# 	-- Basic Information --
#
# Maintained By : Wolfgang Baird
# Version 		: 1.2
# Updated 		: Jun / 11 / 2015
# Icons 		: © Apple Inc.
#
#	-- Basic Information --

my_dl() {
	curl -\# -L -o "$appsupport_dir"/icns.zip "https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/icons.zip" 2> /tmp/updateTracker &
	pids="$pids $!"
	wait_for_process $pids
}
wait_for_process() {
	dlp="Downloading"
	local i=0
    local errors=0
    while :; do
        debug "Processes remaining: $*"
        for pid in "$@"; do
            shift
            if kill -0 "$pid" 2>/dev/null; then
                debug "$pid is still alive."
                set -- "$@" "$pid"
				if [[ $i = 3 ]]; then i=0; printf "\b\b\b   \b\b\b"; fi
				((i++))
                output=$(tail -n 1 /tmp/updateTracker)
                output=${output##* }
				if [[ "$output" == *"%" ]]; then
				    output=$output%
				fi
                if [[ $num = 0 ]]; then
                	dlp=".   $output"
                	num=1
                elif	[[ $num = 1 ]]; then
                	dlp="..  $output"
                	num=2
                else
                	dlp="... $output"
                	num=0
                fi
                printf "\r$key_word$dlp" 2> /dev/null
            elif wait "$pid"; then
            	debug "$pid exited with zero exit status."
                printf "\r$key_word... 100%% \n"
                sleep 1
            else
                debug "$pid exited with non-zero exit status."
				printf "\n"
                ((++errors))
            fi
        done
        (("$#" > 0)) || break
        sleep ${WAITALL_DELAY:-.1}
    done
    ((errors == 0))
	rm -f /tmp/updateTracker
}
debug() {
	echo "DEBUG: $*" >/dev/null
}
internet_check() {
	echo "DO STUFF"
}
vercomp() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}
verres() {
	vercomp "$1" "$2"
	case $? in
		0) output='=';;
        1) output='>';;
        2) output='<';;
	esac
	echo $output
}

BG='\033[40m'			# BLACK BACKGROUND
RB='\033[0;31m\033[40m'	# RED
GN='\033[0;32m\033[40m' # GREEN
OR='\033[1;33m\033[40m' # ORANGE
WT='\033[0;37m\033[40m' # WHITE
PU='\033[0;35m\033[40m' # PURPLE
NC='\033[0m'			# NO COLOR

move_icons=1
key_word="${WT}Fetching icons${GN}"
appsupport_dir="$HOME"/Library/Application\ Support/ycf

# OSX version & Rootless check
OSX_version=$(sw_vers -productVersion)
OSX_version=$(verres 10.11 $OSX_version)
if [[ $OSX_version != "<" ]]; then
	nvram_bootargs=$(nvram boot-args)
	are_we_rootless=0
	if [[ "$nvram_bootargs" = *"rootless=0"* ]]; then are_we_rootless=1; fi
fi

# Clear terminal window
printf "${BG}"
clear && printf '\e[3J'

# Print basic information
printf "\
${WT}About   : ${RB}Classic Folders\n\
${WT}Author  : ${RB}Wolfgang Baird\n\
${WT}Version : ${RB}1.2\n\
${WT}Updated : ${RB}Jun / 11 / 2015\n\
${WT}Changes : ${RB}El Capitan support (Rootless bypass), Misc fixes, Colored output 
${WT}Icons   : ${RB}© Apple Inc.\n\n\
${OR}This script requires that you enter your ${GN}password${OR} to continue.\n\
You won't see your ${GN}password${OR} as you type it.\n\
Press return once you've finished typing your ${GN}password${OR}.\n\n"

# Ask for password
sudo -v

if [[ $OSX_version != "<" ]]; then
	if [[ "$are_we_rootless" = "0" ]]; then
		printf "\
${PU}Classic Folders ${WT}has determined that ${RB}Rootless ${WT}is currently enabled on your system.
Unfortunately this will prevent ${PU}Classic Folders ${WT}from doing anything.
You have ${GN}two${WT} options:

${GN}y${WT}: To continue and disable ${RB}Rootless ${WT}enter '${GN}y${WT}' and press return. 
This will cause your system to reboot. 
You will need to run ${PU}Classic Folders ${WT}again after your System reboots.

${GN}n${WT}: To cancel and do nothing enter '${GN}n${WT}' and press return. 
This will close ${PU}Classic Folders ${WT}and nothing will be changed.

Disable ${RB}Rootless ${WT}(${GN}y${WT}/${GN}n${WT}): "
		read res_me0
		if [[ $res_me0 = "y" ]]; then
			# Add rootless=0 to nvram boot-args and reboot
			ba=$(nvram boot-args | sed -E "s/boot-args|rootless=.//g")
			sudo nvram boot-args="rootless=0$(if [[ $ba = *[!\ ]* ]];then printf " ";echo ${ba[*]};fi)"
			# sudo reboot
		else
			exit
		fi
	fi
fi

# Get trash script
# curl -\# -L -o "$appsupport_dir"/trash "https://github.com/w0lfschild/classic_Yose/blob/master/trash?raw=true"
# chmod 755 "$appsupport_dir"/trash
# printf "\n"

# Get icons
if [[ ! -e "$appsupport_dir"/icons ]]; then mkdir -p "$appsupport_dir"/icons; fi
if [[ ! -e "$appsupport_dir"/icns.zip ]]; then
	# echo -e "Fetching icons"
	# curl -\# -L -o "$appsupport_dir"/icns.zip "https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/icons.zip"
	my_dl
	unzip "$appsupport_dir"/icns.zip -d "$appsupport_dir"/icons >/dev/null
fi

# Check for backup
if [[ ! -e /System/Library/CoreServices/.CoreTypes.bundle.old ]]; then	
	# Backup existing CoreTypes
	printf "${WT}Backing up ${RB}CoreTypes ${GN}to \"/System/Library/CoreServices/.CoreTypes.bundle.old\"\n"
	sudo cp -r /System/Library/CoreServices/CoreTypes.bundle /System/Library/CoreServices/.CoreTypes.bundle.old
else
	printf "\n${OR}CoreTypes ${RB}Backup Detected!\n${WT}Would you like to ${GN}restore ${WT}from it now? (${GN}y${WT}/${GN}n${WT}): "
	read res_me
	if [[ $res_me = "y" ]]; then
		move_icons=0
		printf "${GN}Restoring ${WT}from ${OR}CoreTypes ${WT}backup${NC}\n"
		sudo rm -rf /System/Library/CoreServices/CoreTypes.bundle
		sudo mv /System/Library/CoreServices/.CoreTypes.bundle.old /System/Library/CoreServices/CoreTypes.bundle
	else 
		printf "${RB}Overwrite ${WT}existing backup? ${WT}(${GN}y${WT}/${GN}n${WT}): "
		read res_me1
		if [[ $res_me1 = "y" ]]; then
			sudo cp -rf /System/Library/CoreServices/CoreTypes.bundle /System/Library/CoreServices/.CoreTypes.bundle.old
		fi
	fi
fi

# Moving icons
if [[ $move_icons = 1 ]]; then
	printf "${WT}Moving icons ${GN}to \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources\"\n"
	sudo cp -rf "$appsupport_dir"/icons/ /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/
fi

# Clear icon caches
printf "${WT}Clearing icon ${OR}caches\n"
sudo find /private/var/folders/ -name com.apple.dock.iconcache -exec rm {} \; 2>/dev/null
sudo find /private/var/folders/ -name com.apple.iconservices -exec rm -rf {} \; 2>/dev/null
osascript -e "tell application \"Finder\"" -e "delete POSIX file \"/Library/Caches/com.apple.iconservices.store\"" -e "End Tell" &>/dev/null
# sudo "$appsupport_dir"/trash /Library/Caches/com.apple.iconservices.store

# Prompt for reboot
printf "
${OR}Done!\n\n\
Now all you need to do is ${RB}reboot${OR} for changes to take effect.\n\
Would you like to ${RB}reboot${OR} now? ${WT}(${GN}y${WT}/${GN}n${WT}): "
read rb_now
printf "${NC}\n"
if [[ $rb_now = "y" ]]; then sudo reboot; fi
