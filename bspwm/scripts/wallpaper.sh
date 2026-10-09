#!/usr/bin/env bash
# Selector de fondos con miniaturas (Rofi) + acento automático.
#
# 1. Elige un fondo de la carpeta WALL_DIR.
# 2. Elige un acento sacado de los colores del fondo (o mantén el actual).
# El fondo se aplica con nitrogen en todos los monitores.

WALL_DIR="${WALL_DIR:-$HOME/Downloads/Wallpapers}"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpicker"
RICE="$HOME/.config/rice"
THEME="$HOME/.config/rofi/wallpaper.rasi"

mkdir -p "$CACHE"
notify() { command -v notify-send >/dev/null && notify-send -a Fondo "$@"; }

mapfile -t walls < <(find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort)
if [ ${#walls[@]} -eq 0 ]; then
    notify -u critical "No hay fondos" "Pon imágenes en $WALL_DIR"
    exit 1
fi

current=$(sed -n 's/^file=//p' "$HOME/.config/nitrogen/bg-saved.cfg" 2>/dev/null | head -n1)

# Miniaturas en caché (se regeneran si la imagen cambia)
thumb_for() {
    local key thumb
    key=$(printf '%s%s' "$1" "$(stat -c %Y "$1")" | md5sum | cut -c1-16)
    thumb="$CACHE/$key.png"
    [ -f "$thumb" ] || ffmpeg -loglevel error -y -i "$1" \
        -vf "scale=480:270:force_original_aspect_ratio=increase,crop=480:270" \
        -frames:v 1 "$thumb"
    echo "$thumb"
}

active=""
for i in "${!walls[@]}"; do
    [ "${walls[$i]}" = "$current" ] && active=$i
done

# Una entrada por fondo: "nombre\0icon\x1fminiatura" (el \0 no cabe en una
# variable de bash, por eso se imprime directo a Rofi)
list_entries() {
    local w
    for w in "${walls[@]}"; do
        printf '%s\0icon\x1f%s\n' "$(basename "${w%.*}")" "$(thumb_for "$w")"
    done
}

choice=$(list_entries | rofi -dmenu -i -theme "$THEME" -format i -no-custom \
    -p "  Fondos" -selected-row "${active:-0}" ${active:+-a "$active"} \
    -me-select-entry '' -me-accept-entry MousePrimary)
[ -z "$choice" ] && exit 0
wall=${walls[$choice]}

# ── Aplicar en cada monitor ──
heads=$(xrandr --listmonitors 2>/dev/null | head -n1 | awk '{print $2}')
for ((h = 0; h < ${heads:-1}; h++)); do
    nitrogen --head="$h" --set-zoom-fill --save "$wall" 2>/dev/null
done

# ── Elegir acento ──
# shellcheck source=/dev/null
source "$RICE/accent"
mapfile -t pairs < <(python3 -I "$RICE/wallcolor.py" "$wall" --all)

rows=()
for p in "${pairs[@]}"; do
    a=${p% *}; s=${p#* }
    rows+=("<span color='$a'>██████</span><span color='$s'>███</span>   $a")
done
rows+=("<span color='$ACCENT'>██████</span><span color='$SECONDARY'>███</span>   Mantener el actual")

pick=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -markup-rows -no-custom -format i \
    -l ${#rows[@]} -p "  Acento" -mesg "<b>Elige el acento para este fondo</b>" \
    -theme-str 'window { width: 380px; } mainbox { children: [ message, listview ]; }' \
    -me-select-entry '' -me-accept-entry MousePrimary)

if [ -n "$pick" ] && [ "$pick" -lt "${#pairs[@]}" ]; then
    p=${pairs[$pick]}
    "$RICE/set-accent.sh" "${p% *}" "${p#* }"
else
    notify "Fondo cambiado" "$(basename "$wall")"
fi
