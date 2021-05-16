#!/bin/bash
# Check if dunst is running
if pgrep -x "dunst" > /dev/null
then
    is_paused=$(dunstctl is-paused)

    if [[ $is_paused == 'false' ]]; then
        status_icon=" on"
    elif [[ $is_paused == 'true' ]]; then
        status_icon=" off"
    fi
else
    status_icon=" off"
fi

echo $status_icon
