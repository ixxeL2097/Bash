#!/bin/bash

GREEN="\\033[1;32m"
WHITE="\\033[0;39m"
RED="\\033[1;31m"
CYAN="\\033[1;36m"
YELLOW="\\033[1;33m"
BLUE="\\033[1;34m"
cmd=''
DATE=$(date +%Y-%m-%d:%H:%M:%S)

#---------------------------------------------------FUNCTIONS------------------------------------------------------------------------------

function checkUser
{
    if [ "$SUDO_USER" = "" ];then
        echo -e "$RED""[WARNING] : IT SEEMS YOU EXECUTED SCRIPT AS ROOT, WE RECOMMAND YOU TO EXECUTE SCRIPT AS STANDARD USER WITH SUDO COMMAND..."
        read -p "Do you want to continue anyway ? [y/n] : " ANSWER
        if [ $ANSWER = "n" ];then
            exit
        fi
    fi
}

function EnableSudoers
{
    echo -e "$BLUE"
    read -p "Do you want to make a specific user sudoers ? [y/n] : " ANSWER1
    if [ $ANSWER1 = "y" ];then
        read -p "Please give user's name ? : " NAME
        echo -e "$WHITE"
        /usr/bin/apt-get install sudo
        /usr/bin/usermod -a -G sudo $NAME
        echo -e "$RED""[WARNING] : WE STRONGLY RECOMMAND YOU TO REBOOT SYSTEM."
        read -p "Do you want to reboot now ? [y/n] : " ANSWER2
        if [ $ANSWER2 = "y" ];then
            /sbin/reboot
        fi
    fi
}

