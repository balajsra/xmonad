#!/bin/bash
if ! num_updates=$(paru -Qu 2>/dev/null | wc -l); then
    # if ! updates_aur=$(yay -Qum 2>/dev/null | wc -l); then
    # if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
    # if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
    # if ! updates_aur=$(pikaur -Qua 2> /dev/null | wc -l); then
    # if ! updates_aur=$(rua upgrade --printonly 2> /dev/null | wc -l); then
    num_updates=0
fi

echo "$num_updates"
