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

function VboxGuest
{
    echo -e "$YELLOW""[SCRIPT] : Starting VBox Guest Additions install...""$WHITE"
    /usr/bin/apt install gcc build-essential module-assistant dkms linux-headers-$(uname -r) -y #build-essential module-assistant dkms
    m-a prepare
    if mount | grep /media/cdrom > /dev/null; then
        echo "Media already mounted"
    else
        echo "Media mounting now..."
        /bin/mount /media/cdrom
    fi
    sh /media/cdrom/./VBoxLinuxAdditions.run
}

function FullUpdate
{
    echo -e "$YELLOW""[SCRIPT] : UPDATING REPOS...""$WHITE"
    /usr/bin/apt update -y
    echo -e "$YELLOW""[SCRIPT] : SOFT UPGRADING...""$WHITE"
    /usr/bin/apt upgrade -y
    echo -e "$YELLOW""[SCRIPT] : HARD UPGRADING...""$WHITE"
    /usr/bin/apt full-upgrade -y
    echo -e "$YELLOW""[SCRIPT] : CLEANING USELESS PACKAGES...""$WHITE"
    /usr/bin/apt autoremove -y
    /usr/bin/apt clean -y
}

function zshInstall
{
    echo -e "$YELLOW""[SCRIPT] : GRANTING SUDO ACCESS TO NORMAL USER...""$WHITE"
    grantSudo
    echo -e "$YELLOW""[SCRIPT] : INSTALLING ZSH, CURL and GIT...""$WHITE"
    /usr/bin/apt install zsh -y
    /usr/bin/apt install curl -y
    /usr/bin/apt install git -y
    echo -e "$YELLOW""[SCRIPT] : INSTALLING OH-MYZ.SH FOR ROOT...""$WHITE"
    /usr/bin/curl -L http://install.ohmyz.sh | sh
    /bin/sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"dallas\"/g" "$HOME""/.zshrc"
    grantedUser=$(ls /home)
    if [ $grantedUser != "" ];then
        echo -e "$YELLOW""[SCRIPT] : INSTALLING OH-MYZ.SH FOR USER...""$WHITE"
        su - $grantedUser -c "/usr/bin/curl -L http://install.ohmyz.sh | sh"
        /bin/sed -i "s/ZSH_THEME=\".*\"/ZSH_THEME=\"gnzh\"/g" "/home/""$grantedUser""/.zshrc"
        /usr/bin/chsh -s /bin/zsh $grantedUser
    fi
}

function DebianFreshInstall
{
    echo -e "$YELLOW""[SCRIPT] : GRANTING SUDO ACCESS TO NORMAL USER...""$WHITE"
    grantSudo
    echo -e "$YELLOW""[SCRIPT] : SETTING HOSTNAME...""$WHITE"
    OLD=$(hostname)
    /bin/hostname "$HOST"
    /bin/sed -i "s/""$OLD""/""$HOST""/g" /etc/hosts
    echo -e "$YELLOW""[SCRIPT] : MODIFYING SOURCES LIST...""$WHITE"
    /bin/sed -i "s/main/main contrib non-free/g" /etc/apt/sources.list
    /usr/bin/apt update -y
    echo -e "$YELLOW""[SCRIPT] : INSTALLING USUAL SOFTWARES FOR FRESH DEBIAN INSTALL...""$WHITE"
    DebCommonPackages
    if [ $MULTIMEDIA = "y" ];then
        echo -e "$YELLOW""[SCRIPT] : INSTALLING MULTIMEDIA PACKAGE...""$WHITE"
        DebMultimediaPackages
    fi
}

function grantSudo
{
    /usr/bin/apt install sudo -y
    grantedUser=$(ls /home)
    /usr/sbin/usermod -a -G sudo $grantedUser
}

function DebCommonPackages
{
    /usr/bin/apt install net-tools build-essential debian-keyring -y
    /usr/bin/apt install rsync firmware-linux -y
    #/usr/bin/apt install ufw -y
    /bin/sed -i "s/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/g" /etc/default/grub
    /usr/sbin/update-grub
}

function DebMultimediaPackages
{
    /usr/bin/apt install synaptic apt-xapian-index gdebi gksu -y
    /usr/bin/apt install vlc -y
    /usr/bin/apt install gufw -y
}

function OMVInstall
{
    echo -e "$RED""[SCRIPT] : INSTALLING OpenMediaVault ARRAKIS...""$WHITE"
    echo "deb [trusted=yes] http://packages.openmediavault.org/public arrakis main" > /etc/apt/sources.list.d/openmediavault.list
    #/usr/bin/apt install dirmngr -y  
    #gpg --keyserver pgpkeys.mit.edu --recv-key  24863F0C716B980B      
    #gpg -a --export 24863F0C716B980B | apt-key add -
    echo -e "$RED""[SCRIPT] : adding key...""$WHITE"
    /usr/bin/wget -O - http://packages.openmediavault.org/public/archive.key | apt-key add -
    /usr/bin/apt update -y
    echo -e "$RED""[SCRIPT] : install OMV keyring...""$WHITE"
    /usr/bin/apt install openmediavault-keyring -y
    /usr/bin/apt update -y
    echo -e "$RED""[SCRIPT] : install postfix...""$WHITE"
    /usr/bin/apt install postfix -y
    /usr/bin/apt update -y
    echo -e "$RED""[SCRIPT] : install OMV...""$WHITE"
    /usr/bin/apt install openmediavault -y
    echo -e "$RED""[SCRIPT] : init...""$WHITE"
    /usr/sbin/omv-initsystem
    /usr/sbin/omv-firstaid
    /usr/bin/wget -O - http://omv-extras.org/install | bash
}

function fail2banInstall
{
    echo -e "$RED""[SCRIPT] : FAIL2BAN PROTECTING SSH, PROFTPD & NGINX BY DEFAULT...""$WHITE"
    /usr/bin/apt install fail2ban -y
    /bin/sed "/^\[sshd\]$/,/^port/s/^$/enabled = true/" /etc/fail2ban/jail.conf > /etc/fail2ban/jail.local
    /bin/sed -i "/^\[sshd\]$/,/^port/s/^port/filter = sshd\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[sshd\]$/,/^port/s/^port/bantime = 900\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[sshd\]$/,/^port/s/^port/maxretry = 4\n&/" /etc/fail2ban/jail.local

    /bin/sed -i "/^\[proftpd\]$/,/^port/s/^$/enabled = true/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[proftpd\]$/,/^port/s/^port/filter = proftpd\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[proftpd\]$/,/^port/s/^port/bantime = 900\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[proftpd\]$/,/^port/s/^port/maxretry = 4\n&/" /etc/fail2ban/jail.local

    /bin/sed -i "/^\[nginx-http-auth\]$/,/^port/s/^$/enabled = true/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[nginx-http-auth\]$/,/^port/s/^port/filter = nginx-http-auth\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[nginx-http-auth\]$/,/^port/s/^port/bantime = 900\n&/" /etc/fail2ban/jail.local
    /bin/sed -i "/^\[nginx-http-auth\]$/,/^port/s/^port/maxretry = 4\n&/" /etc/fail2ban/jail.local
    /bin/systemctl enable fail2ban
    #/bin/systemctl status fail2ban
}

function Debian
{
    echo -e "$BLUE"
    read -p "Is it a fresh Debian install (initial setup for new OS system) ? [y/n] : " ANSWER1
    if [ $ANSWER1 = "y" ];then
        read -p "What hostname would you like ? : " HOST
        read -p "Do you want Multimedia package ? (vlc, synaptic...) [y/n] : " MULTIMEDIA
    fi
    echo -e "$BLUE"
    read -p "Install VBox Guest Additions (only for VBox VMs!) ? [y/n] : " ANSWER2
    if [ $ANSWER2 = "y" ];then
        echo -e "$RED""[WARNING] : PLEASE, INSERT GUEST ADDITIONS ISO-CD FROM VBox GUI !!!"
        read -p "OK ? [y/n] : " OK
    fi
    echo -e "$BLUE"
    read -p "Install ZSH (oh-myz-sh themes root=>dallas / user=>gnzh) ? [y/n] : " ANSWER3
    echo -e "$BLUE"
    read -p "Install OpenMediaVault v4 - Arrakis build ? [y/n] : " ANSWER4
    echo -e "$BLUE"
    read -p "Install Fail2ban ? [y/n] : " ANSWER5
    FullUpdate
    if [ $ANSWER1 = "y" ];then
        DebianFreshInstall
        FullUpdate
    fi
    if [ "$OK" = "y" ];then
        VboxGuest
    fi
    if [ $ANSWER3 = "y" ];then
        zshInstall
    fi
    if [ $ANSWER4 = "y" ];then
        OMVInstall
    fi
    if [ $ANSWER5 = "y" ];then
        fail2banInstall
    fi
    
}

#------------------------------------------------SCRIPT------------------------------------------------

echo -e "$GREEN""Executing Debian 9 - Stretch Install Script : "$DATE
Debian
echo -e "$GREEN""[SCRIPT] : INSTALLATION SUCCESS !!!""$WHITE"
echo -e "$GREEN""[SCRIPT] : Please reboot your system""$WHITE"