#! /bin/bash

alacritty msg config "$(cat ~/.config/alacritty/selenized_${1}.toml)" -w -1
ln -sf "${HOME}/.config/alacritty/selenized_${1}.toml" "${HOME}/.config/alacritty/theme.toml"
