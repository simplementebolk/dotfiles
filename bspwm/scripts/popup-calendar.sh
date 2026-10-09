#!/bin/sh
# Calendario flotante (yad) bajo Polybar, centrado en el ratón.
# Un segundo clic lo cierra.

BAR_HEIGHT=50  # alto de polybar + offset-y + margen
YAD_WIDTH=222  # 222 es el mínimo posible
YAD_HEIGHT=193 # 193 es el mínimo posible
MARGIN=12      # igual que window_gap de bspwm

case "$1" in
--popup)
    # Si ya está abierto, cerrarlo
    if pkill -f '^yad --calendar'; then
        exit 0
    fi

    eval "$(xdotool getmouselocation --shell)"

    # Geometría del monitor bajo el ratón
    eval "$(bspc query -T -m pointed | jq -r '.rectangle | "MX=\(.x) MY=\(.y) MW=\(.width) MH=\(.height)"')"

    # Centrar en el ratón sin salir del monitor
    pos_x=$((X - YAD_WIDTH / 2))
    [ "$pos_x" -lt "$((MX + MARGIN))" ] && pos_x=$((MX + MARGIN))
    [ "$((pos_x + YAD_WIDTH))" -gt "$((MX + MW - MARGIN))" ] && pos_x=$((MX + MW - MARGIN - YAD_WIDTH))
    pos_y=$((MY + BAR_HEIGHT))

    yad --calendar --undecorated --fixed --close-on-unfocus --no-buttons \
        --width=$YAD_WIDTH --height=$YAD_HEIGHT --posx=$pos_x --posy=$pos_y \
        --title="yad-calendar" --class="yad-calendar" --borders=8 >/dev/null &
    ;;
*)
    date +" %A, %e de %B"
    ;;
esac
