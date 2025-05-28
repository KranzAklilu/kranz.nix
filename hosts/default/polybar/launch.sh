#!/usr/bin/env bash

# Terminate already running bar instances
killall -q .polybar-wrapper

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch the bar
# polybar --reload -q main -c $HOME/.config/polybar/config.ini &
# polybar --reload -q secondary -c $HOME/.config/polybar/config.ini &

monitor-affinity -a primary -e MONITOR polybar main
monitor-affinity -a not-primary -e MONITOR polybar secondary
