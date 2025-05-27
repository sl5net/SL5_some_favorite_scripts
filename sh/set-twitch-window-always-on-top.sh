xdotool search --onlyvisible --name "Twitch" | while read -r window_id; do wmctrl -i -r "$window_id" -b add,above; done
