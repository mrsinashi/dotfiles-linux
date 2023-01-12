#!/bin/bash
declare -A params=(\
[nohome]="False" \
[upgrade]="True" \
[external]="True" \
[extconf]="True" \
[actions]="True" \
)
#---------------------
polybar_config=(\
[font-0]="Noto Sans:size=12;0" \
[font-1]="FontAwesome:size=14;0" \
[font-2]="DejaVu Sans:size=6;0" \
[font-3]="DejaVu Sans:size=8;0" \
[font-4]="Clear Sans:size=18;0" \
[font-5]="Noto Sans Mono:style=Bold:size=13;0" \
[font-6]="Sinashi:size=13;0" \
[font-7]="Noto Sans:style=Bold:size=12;0" \
[modules-right]="usb-udev weather weather2 ip vpn cpu memory sink volume xkeyboard time date powermenu"
)