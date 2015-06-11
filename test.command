#!/bin/bash

# Notes
# 0 = standard
# 1 = bold
# 30 - 37 text
# 40 - 47 background
#
# Black        0;30
# Blue         0;34
# Green        0;32
# Cyan         0;36
# Red          0;31
# Purple       0;35
# Brown/Orange 0;33
# Light Gray   0;37
#

# printf "I ${RED}love${NC} Stack Overflow\n"

download_wprogress() {
	curl -\# -L -o /tmp/"$applicationName".zip "$downloadURL" 2> /tmp/updateTracker &
	pids="$pids $!"
	wait_for_process $pids
}
my_dl() {
	curl -\# -L -o /Users/w0lf/Desktop/icns.zip "https://raw.githubusercontent.com/w0lfschild/classic_Yose/master/icons.zip" 2> /tmp/updateTracker &
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
the_happening() {
	i=0
	printf "\r$1"
	while [[ $i < 4 ]]
	do
		if [[ $i = 3 ]]; then i=0; printf "\b\b\b   \b\b\b"; fi
		((i++))
	    printf "."
		sleep 0.5
	done
}

BG='\033[40m'
RB='\033[0;31m\033[40m'
GN='\033[0;32m\033[40m'
OR='\033[1;33m\033[40m'
WT='\033[0;37m\033[40m'
PU='\033[0;35m\033[40m'
NC='\033[0m' # No Color

printf "${BG}"
clear && printf '\e[3J'

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

printf "\
${PU}Classic Folders ${WT}has determined that ${RB}Rootless ${WT}is currently enabled on your system.
Unfortunately this will prevent ${PU}Classic Folders ${WT}from doing anything.
You have ${GN}two${WT} options:

${GN}y${WT}: To continue and disable ${RB}Rootless ${WT}enter '${GN}y${WT}' and press return. 
This will cause your system to reboot. 
You will need to run ${PU}Classic Folders ${WT}again after your System reboots.

${GN}n${WT}: To cancel and do nothing enter '${GN}n${WT}' and press return. 
This will close ${PU}Classic Folders ${WT}and nothing will be changed.

Disable ${RB}Rootless ${WT}(${GN}y${WT}/${GN}n${WT}): \n\n"

key_word="${BG}${WT}Fetching icons${GN}"
my_dl

printf "${WT}Backing up ${OR}CoreTypes ${GN}to \"/System/Library/CoreServices/.CoreTypes.bundle.old\"\n"
printf "${WT}Moving icons ${GN}to \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources\"\n"
printf "${WT}Clearing icon ${OR}caches\n"

printf "\n${OR}CoreTypes ${RB}Backup Detected!\n\
${WT}Would you like to ${GN}restore ${WT}from it now? (${GN}y${WT}/${GN}n${WT}): \n"
printf "${GN}Restoring ${WT}from ${OR}CoreTypes ${WT}backup\n"
printf "${RB}Overwrite ${WT}existing backup? ${WT}(${GN}y${WT}/${GN}n${WT}): \n"
printf "${WT}Moving icons ${GN}to \"/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources\"\n"
printf "${WT}Clearing icon ${OR}caches\n\n"

printf "${OR}Done!\n\n\
Now all you need to do is ${RB}reboot${OR} for changes to take effect.\n\
Would you like to ${RB}reboot${OR} now? ${WT}(${GN}y${WT}/${GN}n${WT}): "

printf "${NC}\n"