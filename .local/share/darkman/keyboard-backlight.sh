#!/usr/bin/env sh

# Control keyboard backlight based on mode. Should be vendor agnostic.
# reference https://wiki.archlinux.org/title/Keyboard_backlight#D-Bus

# Check the max brightness value for your hardware with:
# dbus-send --type=method_call --print-reply=literal --system --dest="org.freedesktop.UPower" /org/freedesktop/UPower/KbdBacklight org.freedesktop.UPower.KbdBacklight.GetMaxBrightness

case "$1" in
dark) BRIGHTNESS=1 ;;  # Activate keyboard backlight in dark mode
light) BRIGHTNESS=0 ;; # Disable keyboard backlight in light mode
default) exit 1 ;;
esac

dbus-send --system --type=method_call --dest="org.freedesktop.UPower" "/org/freedesktop/UPower/KbdBacklight" "org.freedesktop.UPower.KbdBacklight.SetBrightness" "int32:$BRIGHTNESS"
