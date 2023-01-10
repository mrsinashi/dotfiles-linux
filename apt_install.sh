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

apt_ext_config() {
    if [[ $external == "True" ]]
    then
        install_google-chrome-stable
        install_code
        install_postgresql-14
        install_pgadmin4
        install_install_python3.10
        install_poetry
        install_node-js
    fi
}

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

    if [[ $external == "True" ]]
    then
        install_google-chrome-stable
        install_code
        install_postgresql-14
        install_pgadmin4
        install_install_python3.10
        install_poetry
        install_node-js

        apt install -y $install_packages[@];
    fi
}


install_google-chrome-stable() {
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -;
    sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list';
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A8580BDC82D3DC6C;
    
    install_packages+=(google-chrome-stable)
}

install_code() {
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg;
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg;
    sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list';
    rm -f packages.microsoft.gpg;
    
    install_packages+=(code)
}

install_postgresql-14() {
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list';
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -;
    install_packages+=(postgresql-14)
}

install_pgadmin4() {
    curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg;
    sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update';
    install_packages+=(pgadmin4-web)
}

install_install_python3.10() {
    apt-get install -y libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev;

    wget https://www.python.org/ftp/python/3.10.9/Python-3.10.9.tgz;
    tar -xvf Python-3.10.9.tgz;
    cd Python-3.10.9/;
    ./configure --enable-optimizations;
    make -j 2;
    make altinstall;
}

install_poetry() {
    curl -sSL https://install.python-poetry.org | python3.10 -;
    manual_actions+=('export PATH="/home/user/.local/bin:$PATH"');
}

install_node-js() {
    curl -fsSL https://deb.nodesource.com/setup_18.x | -E bash -;
    install_packages+=(nodejs)
    add_actions=+('npm install --global yarn;')
}


while [ -n "$1" ]
do
    case "$1" in
        "--all")
            install_samples=(Base WM Additional Dev Home)
            upgrade="True"
            external="True"
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
        "--ext")
            external="True"
            ;;
        "--noext")
            external="False"
            ;;
        *)
            echo -e "\033[0;31m\033[1mInvalid argument (\033[0m$1\033[0;31m\033[1m)"
            exit
            ;;
    esac
    shift
done

apt_ext_config
apt_update
apt_upgrade
apt_install


for action in ${add_actions[@]}
do
    action
done