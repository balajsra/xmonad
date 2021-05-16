#!/bin/bash
BAR="mybar"
CONFIG="~/.xmonad/polybar/config.ini"
NUM_MONITORS=0
CONNECTED_MONITORS=$(xrandr --query | grep " connected" | cut -d" " -f1)
TRAY_POS="right"

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

rm /tmp/polybar.pids
sleep 1

for m in $CONNECTED_MONITORS; do
    let "NUM_MONITORS+=1"
done

if [ $NUM_MONITORS == 1 ]; then
    # Launch on only monitor w/ systray
    MONITOR=$CONNECTED_MONITORS TRAY_POS=$TRAY_POS polybar --reload -c $CONFIG $BAR &
else
    PRIMARY=$(xrandr --query | grep " connected" | grep "primary" | cut -d" " -f1)
    OTHERS=$(xrandr --query | grep " connected" | grep -v "primary" | cut -d" " -f1)

    # Launch on primary monitor w/ systray
    MONITOR=$PRIMARY TRAY_POS=$TRAY_POS polybar --reload -c $CONFIG $BAR &
    sleep 1

    # Launch on all other monitors w/o systray
    for m in $OTHERS; do
        MONITOR=$m TRAY_POS=none polybar --reload -c $CONFIG $BAR &
    done
fi

echo "$!" >>/tmp/polybar.pids
