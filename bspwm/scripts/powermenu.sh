#!/usr/bin/env bash
# Menú de energía con Rofi: bloquear, cerrar sesión, reiniciar y apagar.
# Las acciones que cierran la sesión piden confirmación.

THEME="$HOME/.config/rofi/powermenu.rasi"

DIM="#6c7086"
I_LOCK=$'\U000F033E'     # 󰌾
I_LOGOUT=$'\U000F0343'   # 󰍃
I_REBOOT=$'\U000F0709'   # 󰜉
I_POWER=$'\U000F0425'    # 󰐥
I_CLOCK=$'\U000F0954'    # 󰥔

# Tiempo encendido en español: "2 h 15 min"
read -r up _ < /proc/uptime
up=${up%.*}
days=$(( up / 86400 )); hours=$(( up % 86400 / 3600 )); mins=$(( up % 3600 / 60 ))
uptime_text=""
[ "$days" -gt 0 ]  && uptime_text+="$days d "
[ "$hours" -gt 0 ] && uptime_text+="$hours h "
uptime_text+="$mins min"

mesg="<b>$USER</b>   <span color='$DIM'>$I_CLOCK $uptime_text</span>"

rows=(
    "<span color='#a6adc8'>$I_LOCK</span>  Bloquear"
    "<span color='#a6adc8'>$I_LOGOUT</span>  Cerrar sesión"
    "<span color='#f0b44c'>$I_REBOOT</span>  Reiniciar"
    "<span color='#e5484d'>$I_POWER</span>  Apagar"
)

rofi_menu() {
    rofi -dmenu -theme "$THEME" -markup-rows -no-custom -format i \
        -me-select-entry '' -me-accept-entry MousePrimary "$@"
}

# Pide confirmación antes de una acción destructiva.
# $1 = pregunta, $2 = texto del botón
confirm() {
    local answer
    answer=$(printf '%s\n' \
        "<span color='#e5484d'>󰄬</span>  $2" \
        "<span color='$DIM'>󰜺</span>  Cancelar" |
        rofi_menu -l 2 -mesg "<b>$1</b>")
    [ "$answer" = 0 ]
}

choice=$(printf '%s\n' "${rows[@]}" | rofi_menu -l ${#rows[@]} -mesg "$mesg")

case "$choice" in
    0) "$HOME/.config/bspwm/scripts/lock.sh" ;;
    1) confirm "¿Cerrar la sesión?"    "Sí, cerrar sesión" && bspc quit ;;
    2) confirm "¿Reiniciar el equipo?" "Sí, reiniciar"     && systemctl reboot ;;
    3) confirm "¿Apagar el equipo?"    "Sí, apagar"        && systemctl poweroff ;;
esac
