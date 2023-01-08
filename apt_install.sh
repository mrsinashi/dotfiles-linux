#!/bin/bash

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

Base_packages=(nvidia-driver-525 curl util-linux apt-transport-https wget gpg htop x11-utils udisks2 jq mlocate lxqt-sudo pavucontrol cmake nginx)
WM_packages=(i3 polybar lightdm fonts-font-awesome fonts-noto rofi hsetroot wmctrl gsimplecal numlockx)
Additional_packages=(thunar xfce4-terminal xarchiver inkscape vlc virtualbox qbittorrent openvpn easy-rsa virtualbox-ext-pack evolution filezilla kolourpaint flameshot telegram-desktop gpick)
Dev_packages=(redis)
Home_packages=(steam cryptomator)

apt_update() {
    echo -e "\033[1m\033[7mStarting apt update packages...\033[0m";
    apt update;
    echo -e "\033[0;32m\033[1m\033[7mUpdating packages succesfull\033[0m";
}

apt_upgrade() {
    if [[ $upgrade == "True" ]]
    then
        echo -e "\033[1m\033[7mStarting apt upgrade packages...\033[0m";
        apt upgrade -y;
        echo -e "\033[0;32m\033[1m\033[7mUpgrading packages succesfull\033[0m";
    fi
}

apt_install() {
    echo -e "\033[1m\033[7mStarting apt install packages...\033[0m";
    for sample in ${install_samples[@]}
    do
        eval apt install -y "\${${sample}_packages[@]}";
        echo -e "\033[0;32m\033[1m${sample} packages installed!\033[0m";
    done
    echo -e "\033[0;32m\033[1m\033[7mInstalling packages succesfull\033[0m";
}

while [ -n "$1" ]
do
    case "$1" in
        "--all")
            install_samples=(Base WM Additional Dev Home)
            upgrade="True"
            ;;
        "--nohome")
            install_samples=(${install_samples[@]/Home})
            ;;
        "--upgrade")
            upgrade="True"
            ;;
        "--noupgrade")
            upgrade="False"
            ;;
        *)
            echo -e "\033[0;31m\033[1mInvalid argument (\033[0m$1\033[0;31m\033[1m)"
            exit
            ;;
    esac
    shift
done


apt_update
apt_upgrade
apt_install
