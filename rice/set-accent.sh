#!/usr/bin/env bash
# Cambia el color de acento (y el secundario) en todo el rice.
#
# Uso: set-accent.sh "#acento" "#secundario"
#      set-accent.sh                # muestra los colores actuales
#
# Los colores actuales se guardan en ~/.config/rice/accent. El cambio se hace
# reemplazando esos valores exactos en cada archivo, así que deben ser únicos
# (ningún otro color del rice usa #e5484d o #f0b44c).

set -euo pipefail
CONF="$HOME/.config"
STATE="$CONF/rice/accent"

FILES=(
    "$CONF/bspwm/bspwmrc"
    "$CONF/bspwm/scripts/powermenu.sh"
    "$CONF/bspwm/scripts/rofi-bluetooth.sh"
    "$CONF/polybar/config.ini"
    "$CONF/polybar/scripts/cpu-temp.sh"
    "$CONF/polybar/scripts/music.sh"
    "$CONF/polybar/scripts/network.sh"
    "$CONF/polybar/scripts/rofi-audio.sh"
    "$CONF/rofi/config.rasi"
    "$CONF/dunst/dunstrc"
)

# shellcheck source=/dev/null
source "$STATE"

if [ $# -eq 0 ]; then
    echo "Acento: $ACCENT  Secundario: $SECONDARY"
    exit 0
fi

valid() { [[ $1 =~ ^#[0-9a-fA-F]{6}$ ]]; }
new_accent=${1,,}
new_secondary=${2:-$SECONDARY}; new_secondary=${new_secondary,,}
valid "$new_accent" && valid "$new_secondary" || { echo "Colores inválidos: usa #rrggbb" >&2; exit 1; }
# Deben ser distintos entre sí para poder volver a cambiarlos después
[ "$new_accent" = "$new_secondary" ] && new_secondary=$(printf '#%06x' $(( 0x${new_secondary#\#} ^ 0x000001 )))

# Dos pasos (con marcadores) para que el acento nuevo no choque con el
# secundario viejo ni al revés
for f in "${FILES[@]}"; do
    [ -f "$f" ] || continue
    sed -i -e "s/${ACCENT}/@@RICE_ACCENT@@/gI" -e "s/${SECONDARY}/@@RICE_SECONDARY@@/gI" \
           -e "s/@@RICE_ACCENT@@/${new_accent}/g" -e "s/@@RICE_SECONDARY@@/${new_secondary}/g" "$f"
done
printf 'ACCENT=%s\nSECONDARY=%s\n' "$new_accent" "$new_secondary" > "$STATE"

# ── Aplicar en vivo ──
if pgrep -x bspwm >/dev/null; then
    bspc config focused_border_color  "$new_accent"
    bspc config presel_feedback_color "$new_secondary"
fi
if pgrep -x polybar >/dev/null; then
    "$CONF/polybar/launch.sh" >/dev/null 2>&1 &
fi
if pgrep -x dunst >/dev/null; then
    pkill -x dunst
    while pgrep -x dunst >/dev/null; do sleep 0.05; done
    setsid dunst >/dev/null 2>&1 &
    sleep 0.3
fi
command -v notify-send >/dev/null &&
    notify-send -a Tema "Nuevo acento" "<span color='$new_accent'>████</span> $new_accent   <span color='$new_secondary'>████</span> $new_secondary"
exit 0
