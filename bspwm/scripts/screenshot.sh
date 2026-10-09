#!/usr/bin/env bash
# Menú de capturas de pantalla (Rofi + scrot).
# Guarda en ~/Pictures/Screenshots, copia la imagen al portapapeles (si hay
# xclip) y muestra una notificación con botón para abrirla.

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
# shellcheck source=/dev/null
source "$HOME/.config/rice/accent"

notify_shot() {
    local file=$1 action
    command -v notify-send >/dev/null || return
    action=$(notify-send -a Captura -i "$file" -A open=Abrir -A folder="Ver carpeta" \
        "Captura guardada" "$(basename "$file")")
    case "$action" in
        open)   xdg-open "$file" ;;
        folder) xdg-open "$DIR" ;;
    esac
}

# Número del monitor bajo el ratón (para scrot -M)
monitor_under_pointer() {
    eval "$(xdotool getmouselocation --shell)"
    xrandr --listmonitors | awk -v x="$X" -v y="$Y" 'NR > 1 {
        split($3, g, /[x+\/]/)   # 1920/527x1080/296+0+0 -> w, mmw, h, mmh, x, y
        if (x >= g[5] && x < g[5] + g[1] && y >= g[6] && y < g[6] + g[3]) { print NR - 2; exit }
    }'
}

options=(
    "󰹑  Pantalla completa"
    "󰍹  Monitor actual"
    "󰆞  Seleccionar región o ventana"
    "󰖯  Ventana activa"
    "󰔛  Pantalla completa en 5 s"
)
choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -no-custom -format i \
    -p "󰄀  Captura" -l ${#options[@]} -theme-str 'window { width: 420px; }' \
    -me-select-entry '' -me-accept-entry MousePrimary)
[ -z "$choice" ] && exit 0

file="$DIR/$(date +%Y-%m-%d_%H-%M-%S).png"
sleep 0.35   # esperar a que Rofi se cierre (y su animación de picom)

case "$choice" in
    0) scrot -z -o "$file" ;;
    1) scrot -z -o -M "$(monitor_under_pointer)" "$file" ;;
    2) scrot -z -o -s -f -l "mode=edge,width=2,color=$ACCENT" "$file" ;;
    3) scrot -z -o -u "$file" ;;
    4) scrot -z -o -d 5 -c "$file" ;;
esac || exit 1

[ -f "$file" ] || exit 1
command -v xclip >/dev/null && xclip -selection clipboard -t image/png -i "$file"
notify_shot "$file" &
