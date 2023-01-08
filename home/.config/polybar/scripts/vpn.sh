#!/bin/bash

userfile=$(pgrep -a openvpn$ | awk '{print $NF }')

ovpn_status() {
    if ! [[ $userfile == "" ]]
    then
        vpnstatus=$(cat $userfile | grep "remote " | awk '{print $2}')
        echo "%{B#464B59}%{u#5fcf3b}%{F#5fcf3b}%{T7} M%{T-}%{F#-}  $vpnstatus "
    else
        vpnstatus="Off"
        echo "%{u#cd1f3f}%{F#CD1F3F}%{T7}N%{T-}%{F#-}  $vpnstatus"
    fi
}

ovpn_getfile () {
    find /etc/openvpn/ -name "*.ovpn"
}

ovpn_on() {
    sudo openvpn --config $(ovpn_getfile) &
}

ovpn_off() {
    sudo kill -9 $(pgrep openvpn) &
}

ovpn_toggle() {
    if [[ $vpnstatus == "Off" ]]
    then
        ovpn_on
    else
        ovpn_off
    fi
}

ovpn_update() {
    pid=$(cat "$path_pid")

    if [ "$pid" != "" ]; then
        kill -10 $(pgrep system-vpn) 
    fi
}

path_pid="/tmp/polybar-openvpn.pid"

case "$1" in
    --on)
        ovpn_on
        
        ovpn_update
        ;;
    --off)
        ovpn_off
        
        ovpn_update
        ;;
    --toggle)
        ovpn_toggle
        
        ovpn_update
        ;;
    *)
        echo $$ > $path_pid
        
        ovpn_status
        ;;
esac
