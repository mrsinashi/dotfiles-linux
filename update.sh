#!/bin/bash
default_home="/home/user"
err="false"

red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[36m"
default="\033[0m\n"

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
    *)
        ;;
esac

if [[ $err == "false" ]]
then
    if [[ -d $default_home ]]
    then
        update_configs
    else
        echo -e "\033[31mError:\033[0m Directory ($default_home) not exists"
    fi
fi
