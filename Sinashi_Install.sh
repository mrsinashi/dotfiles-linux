#!/bin/bash
default_home="/home/user"
err="false"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[36m"
default="\033[0m\n"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   exit 1
fi

update_configs() {
    home_dirs=$(cd home; find . -mindepth 1 -type d | sed -r 's/.{,2}//'; cd ..)
    home_files=$(cd home; find . -mindepth 1 -type f | sed -r 's/.{,2}//'; cd ..)
    
    echo -e "\033[33m[HOME]\033[0m\n"
    
    if ! [ -d $default_home/.config/backup ]
    then
        mkdir $default_home/.config/backup -p
        echo -e "Dir ($default_home/.config/backup/) \033[32mcreated\033[0m\n"
    else
        find $default_home/.config/backup/ -type f -delete
        echo -e "Dir ($default_home/.config/backup/) \033[33mcleaned\033[0m\n"
    fi
    
    for dir in ${home_dirs[@]}
    do
        if ! [ -d $default_home/$dir ]
        then
            mkdir $default_home/$dir -p
            echo -e "Dir ($default_home/.config/$dir) \033[32mcreated\033[0m\n"
        fi
        if ! [ -d $default_home/.config/backup/$dir ]
        then
            mkdir $default_home/.config/backup/$dir -p
            echo -e "Dir ($default_home/.config/backup/$dir) \033[32mcreated\033[0m\n"
        fi
    done

    for file in ${home_files[@]}
    do
        mv $default_home/$file $default_home/.config/backup/$file
        echo -e "File ($default_home/$file) \033[33mmoved\033[0m"
        ln home/$file $default_home/$file
        echo -e "Link (\033[36mhome/$file\033[0m) to ($default_home/$file) \033[32mcreated\033[0m\n"
    done


    root_dirs=$(cd root; find . -mindepth 2 -type d | sed -r 's/.{,2}//'; cd ..)
    root_files=$(cd root; find . -mindepth 2 -type f | sed -r 's/.{,2}//'; cd ..)

    echo -e "\033[33m[ROOT]\033[0m\n"

    if ! [ -d $default_home/.config/root_backup ]
    then
        mkdir $default_home/.config/root_backup -p
        echo -e "Dir ($default_home/.config/root_backup/) \033[32mcreated\033[0m\n"
    else
        find $default_home/.config/root_backup/ -type f -delete
        echo -e "Dir ($default_home/.config/root_backup/) \033[33mcleaned\033[0m\n"
    fi
 
    for dir in ${root_dirs[@]}
    do
        if ! [ -d /$dir ]
        then
            mkdir /$dir -p
            echo -e "Dir (/$dir) \033[32mcreated\033[0m\n"
        fi
        if ! [ -d $default_home/.config/root_backup/$dir ]
        then
            mkdir $default_home/.config/root_backup/$dir -p
            echo -e "Dir ($default_home/.config/root_backup/$dir) \033[32mcreated\033[0m\n"
        fi
    done

    for file in ${root_files[@]}
    do
        mv /$file $default_home/.config/root_backup/$file
        echo -e "File (/$file) \033[33mmoved\033[0m"
        ln root/$file /$file
        echo -e "Link (\033[36mroot/$file\033[0m) to (/$file) \033[32mcreated\033[0m\n"
    done

}

edit_config() {
    i3_config=$default_home/.config/i3/config
    search="set \$SCREENWIDTH"
    screensize=$(/usr/bin/xrandr | grep '*' | sed 's|x.*||; s| ||g')
    let screensize=$screensize-230
    set_screensize="set \$SCREENWIDTH $screensize"
    sed -i "s|.*$search.*|$set_screensize|g" $i3_config
    echo -e "File ($i3_config) \033[32mchanged\033[0m"
    echo -e "Parameter (\$SCREENWIDTH) set to $screensize\n"
}

while [ -n "$1" ]
do
    case "$1" in
        --user)
            if [ -n "$2" ]
            then
                default_home="/home/$2"
            else
                echo -e "\033[31mError:\033[0m Username not specified"
                err="true"
            fi
            ;;
        --nohome)
            nohome="--nohome"
            ;;
        --noext)
            noext="--noext"
            ;;
        *)
            echo -e "\033[0;31m\033[1mInvalid argument (\033[0m$1\033[0;31m\033[1m)"
            exit
            ;;
    esac
    shift
done

if [[ $err == "false" ]]
then
    if [[ -d $default_home ]]
    then
        update_configs
        edit_config
    else
        echo -e "\033[31mError:\033[0m Directory ($default_home) not exists"
    fi
fi

./apt_install.sh --all $nohome $noext
