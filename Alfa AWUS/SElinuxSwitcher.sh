#!/bin/bash
GREEN="\\033[1;32m"
WHITE="\\033[0;39m"
RED="\\033[1;31m"
CYAN="\\033[1;36m"

FILE="/etc/sysconfig/selinux"

function switcher
{
    #Checking
    if (grep -R "SELINUX=enforcing" /etc/sysconfig/selinux 1>/dev/null) ; then
        default_mode='SELINUX=enforcing'
        status='enforcing'

    elif (grep -R "SELINUX=permissive" /etc/sysconfig/selinux 1>/dev/null) ; then
        default_mode='SELINUX=permissive'
        status='permissive'

    elif (grep -R "SELINUX=disabled" /etc/sysconfig/selinux 1>/dev/null) ; then
        default_mode='SELINUX=disabled'
        status='disabled'
    else
        status="$RED""Unknown error with SElinux...""$WHITE""Check Configuration file : etc/sysconfig/selinux"
    fi

    echo -e "Current SElinux mode :" "$GREEN""$status""$WHITE"
    echo ""
    sleep 1

    #Switching
    echo "SElinux mode available : "
    echo "  1) Enforcing mode : In enforcing mode, access is restricted according to the SELinux rules in force on the machine"
    echo "  2) Permissive mode : In permissive mode, SELinux rules will be queried, access errors logged, but access will not be blocked (Recommended)"
    echo "  3) Disabled : SELinux is disabled. Nothing will be restricted, nothing will be logged"
    echo "  4) Exit the script"
    echo ""
    read -p '-> Your choice (1/2/3/4) : ' answer

    if [ $answer -eq 1 ]; then 
        new_status='SELINUX=enforcing'

        #set mode on permissive - non permanent
        setenforce 1

        #permanent settings
        sed -i -e "s/$default_mode/$new_status/g" "$FILE"
        echo -e "New SElinux mode : ""$GREEN""enforcing""$WHITE"

    elif [ $answer -eq 2 ]; then
        new_status='SELINUX=permissive'
        
        #set mode on permissive - non permanent
        setenforce 0

        #permanent settings
        sed -i -e "s/$default_mode/$new_status/g" "$FILE"
        echo -e "New SElinux mode : ""$GREEN""permissive""$WHITE"

    elif [[ $answer -eq "3" ]]; then
        new_status='SELINUX=disabled'

        #permanent settings
        sed -i -e "s/$default_mode/$new_status/g" "$FILE"
        echo -e "New SElinux mode : ""$GREEN""disabled""$WHITE"

    elif [ $answer -eq 4 ]; then
        clear
        exit
    fi


    read -r -p "Vérifier la configuration ? [y/N] " final_answer
    if [[ "$final_answer" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        echo ""
        echo -e "$CYAN""SElinux status :""$WHITE"
        echo ""
        sestatus
        echo ""
        echo -e "$CYAN""SElinux Configuration file :""$WHITE"
            cat /etc/sysconfig/selinux 
            echo ""
            read -p "You must reboot for the changes to take effect ! Restart [y/N] ? " restart
            if [[ "$restart" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
                echo "System is going to restart..."
                shutdown -r #Methode propre pour systeme !
            else
                exit
            fi
    else
        exit
    fi
} 

#Root Checking
if (( $EUID != 0 )); then
    echo -e "$RED""You should execute this script as root !""$WHITE"
    echo ""
    sleep 1
    exit
else
    echo -e "$GREEN""Root checking test succeed !\n""$WHITE"
    sleep 1
    echo -e "$CYAN""SElinux status :""$WHITE"
    echo ""
    sestatus
    echo ""
    switcher
fi

