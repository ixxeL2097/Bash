#!/bin/bash

#VARIABLES
GREEN="\\033[1;32m"
RED="\\033[1;31m"
WHITE="\\033[1;39m"
YELLOW="\\033[1;33m"
CYAN="\\033[1;36m"
BLUE="\\033[1;34m"

echo "Wlan1 UP"
    ifconfig wlan1 up
    sleep 1
echo "rmmod rtl"
    rmmod rtl8187
    sleep 1
echo "rfkill and modprobe rtl8187"
    rfkill block all
    sleep 2
    rfkill unblock all
    sleep 1
    modprobe rtl8187
    sleep 1
    rfkill unblock all
echo "ifconfig go"
    ifconfig wlan1 up
    echo -e "$YELLOW""$(ifconfig wlan1)"
echo "lsusb"
    echo -e "$GREEN""$(lsusb)"
    sleep 1
    echo -e "$RED""$(ls -l /sys/class/net/wlan1/device/driver)"
    sleep 1
    echo -e "$WHITE""$(lsmod | grep -i rtl8187)"
    
echo -e "$CYAN""STARTING AIRCRACK INJECTION CHECKING...""$BLUE"
    sleep 1
    airmon-ng check kill
    sleep 5
    airmon-ng start wlan1
    sleep 2
    echo -e "$GREEN"
    aireplay-ng -9 wlan1mon

