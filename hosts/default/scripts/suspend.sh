swayidle -w \
timeout 5m '~/.config/scripts/swaylock.sh' \
timeout 8m ' hyprctl dispatch dpms off' \
timeout 15m 'systemctl suspend' \
resume ' hyprctl dispatch dpms on' \
before-sleep '~/.config/scripts/swaylock.sh'
