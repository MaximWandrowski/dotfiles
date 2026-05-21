#! /bin/bash

alacritty msg config "$(cat ~/.config/alacritty/selenized_${1}.toml)" -w -1
