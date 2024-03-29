#! /bin/bash

# https://github.com/ryanoasis/nerd-fonts
the=(     )
bty=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 󰢟 󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅)
spk=(󰝟 󰕿 󰖀 󰕾 󰕾)
sun=(󰃜 󰃛 󰃚 󰃞 󰃟 󰃠)
gau=(󰡳 󰡵 󰊚 󰡴)
#sig=(󰤮 󰤯 󰤟 󰤢 󰤥 󰤨)

bat=$(cat /sys/class/power_supply/BAT0/capacity)
onl=$(cat /sys/class/power_supply/AC/online)
#dbm=$(iwctl station wlan0 show | awk '/AverageRSSI/ { print $2 }')
mem=$(awk ' /MemTotal/ { t=$2 } ; /MemAvailable/ { f=$2 } ; END { printf("%1.f", (1-f/t)*100) } ' /proc/meminfo)
avg=$(awk ' { printf("%1.f", 100*$1/4) }' /proc/loadavg)
tmp=$(awk '{ print $2 }' /proc/acpi/ibm/thermal)
bri=$(printf "%1.f" $(light -s sysfs/backlight/auto))
vol=$(amixer sget Master | awk 'NR == 4 { max = $5 } ; NR == 6 { printf("%1.f", $4/max*100) }')
mut=$(amixer sget Master | awk '/  Front Left/ { if ($6=="[off]") print 0; else print 1 }')
kbm=$(swaymsg -t get_inputs -p | grep -A 5 -e 'AT Translated' | tail -n 1 | cut -d ' ' -f6)
dat=$(date +'%a %d.%m.%y %H:%M')

echo " ${bty[$bat/10+11*$onl]} ${bat}%  ${sun[$bri/17]}  ${bri}%  ${spk[$mut*((1+$vol/33)*($vol<=100)+4*($vol>100))]} ${vol}%  󰍛 ${mem}%  ${gau[3*$avg/100]} ${avg}%  ${the[$tmp/20]} ${tmp}℃  󰈻 ${kbm}  󰃰  ${dat} "
