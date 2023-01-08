#!/bin/bash
current_sink=$(pacmd list-sinks | grep -e 'name:' -e 'index' | sed -n '{H;$!d};x;s|^\n||;s|\n|:|g;s|.*\*||g;s|>.*||g;s|.*<||g;p;')
free_sink=$(pacmd list-sinks | grep -e 'name:' -e 'index' | sed -n '{H;$!d};x;s|^\n||;s|\n|:|g;s|.*    i||g;s|>.C*||g;s|.*<||g;p;')

config_file="/etc/pulse/default.pa"
search="set-default-sink "
set_sink="set-default-sink $free_sink"

sink_update() {
    pid=$(cat "$path_pid")

    if [ "$pid" != "" ]; then
        kill -10 "$pid"
    fi
}

path_pid="/tmp/polybar-system-change-sink.pid"

case "$1" in
    --change)
        sed -i "s|.*$search.*|$set_sink|g" $config_file
        pacmd "$set_sink"
        
        if ! [[ "$(echo $current_sink | grep -i hdmi)" == "" ]]
        then
            echo "B"
        elif ! [[ "$(echo $current_sink | grep -i usb)" == "" ]]
        then
            echo "A"
        fi

        sink_update
        ;;
    *)
        echo $$ > $path_pid
        trap exit INT
        
        if ! [[ "$(echo $current_sink | grep -i hdmi)" == "" ]]
        then
            echo "A"
        elif ! [[ "$(echo $current_sink | grep -i usb)" == "" ]]
        then 
            echo "B"
        fi
        ;;
esac

