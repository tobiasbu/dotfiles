#!/bin/sh

CALENDAR_APP=orage
BAR_HEIGHT=24  # polybar height
X_OFFSET=28
Y_OFFSET=56 
YAD_WIDTH=222  # 222 is minimum possible value
YAD_HEIGHT=193 # 193 is minimum possible value
DATE="$(date +"%a, %d/%m/%Y %H:%M")"

case "$1" in
--popup)
    if [ "$(xdotool getwindowfocus getwindowname)" = "yad-calendar" ]; then
        exit 0
    fi

    eval "$(xdotool getmouselocation --shell)"
    eval "$(xdotool getdisplaygeometry --shell)"

    # X
    if [ "$((X + YAD_WIDTH / 2 + X_OFFSET))" -gt "$WIDTH" ]; then #Right side
        : $((pos_x = WIDTH - YAD_WIDTH - X_OFFSET))
      elif [ "$((X - YAD_WIDTH / 2 - X_OFFSET))" -lt 0 ]; then #Left side
        : $((pos_x = BORDER_SIZE))
    else #Center
        : $((pos_x = X - YAD_WIDTH / 2))
    fi

    # Y
    if [ "$Y" -gt "$((HEIGHT / 2))" ]; then #Bottom
        : $((pos_y = HEIGHT - YAD_HEIGHT - BAR_HEIGHT - Y_OFFSET))
    else #Top
        : $((pos_y = BAR_HEIGHT + Y_OFFSET))
    fi

    yad --calendar --undecorated --fixed --close-on-unfocus --on-top \
        --width="$YAD_WIDTH" --height="$YAD_HEIGHT" --posx="$pos_x" --posy="$pos_y" \
        --title="yad-calendar" --borders=0 \
        --button="Open Calendar":"${CALENDAR_APP}"
    ;;
*)
    echo "$DATE"
    ;;
esac
