#!/bin/bash
kitty --title "Keybind Cheatsheet" --override initial_window_width=900 --override initial_window_height=600 sh -c "cat ~/.config/hypr/conf/keybinds.conf | grep -E '^bind|^#' | less -R"
