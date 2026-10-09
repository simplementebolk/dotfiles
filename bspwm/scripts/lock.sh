#!/usr/bin/env bash
# Bloquea la pantalla con i3lock usando el fondo de pantalla desenfocado.
# La imagen se genera una vez y se guarda en caché; se regenera sola si
# cambias el fondo (nitrogen) o la disposición de los monitores.

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/lockscreen"
FALLBACK_COLOR="1e1e2e"

if ! command -v i3lock >/dev/null; then
    command -v notify-send >/dev/null &&
        notify-send -u critical -a Bloqueo "i3lock no está instalado" "sudo apt install i3lock"
    exit 1
fi

# No bloquear dos veces
pgrep -x i3lock >/dev/null && exit 0

# Fondo actual de nitrogen
wallpaper=$(sed -n 's/^file=//p' "$HOME/.config/nitrogen/bg-saved.cfg" 2>/dev/null | head -n1)

# Geometría de la pantalla completa y de cada monitor: "WxH+X+Y"
screen=$(xdpyinfo 2>/dev/null | awk '/dimensions:/ { print $2 }')
monitors=$(xrandr --query | grep -oP ' connected( primary)? \K[0-9]+x[0-9]+\+[0-9]+\+[0-9]+')

image="$CACHE/lock-$(printf '%s' "$wallpaper$screen$monitors" | md5sum | cut -c1-12).png"

build_image() {
    local inputs=() filters="" chain="[bg]" i=0 geom w h x y
    mkdir -p "$CACHE"
    rm -f "$CACHE"/lock-*.png
    # Lienzo del tamaño de toda la pantalla
    filters="color=c=#$FALLBACK_COLOR:s=${screen}[bg];"
    for geom in $monitors; do
        w=${geom%%x*}; h=${geom#*x}; h=${h%%+*}
        x=$(cut -d+ -f2 <<< "$geom"); y=$(cut -d+ -f3 <<< "$geom")
        inputs+=(-i "$wallpaper")
        # Escalar y recortar al monitor, desenfocar y oscurecer
        filters+="[$i:v]scale=${w}:${h}:force_original_aspect_ratio=increase,crop=${w}:${h},gblur=sigma=18,eq=brightness=-0.12:saturation=1.1[m$i];"
        filters+="${chain}[m$i]overlay=${x}:${y}:shortest=1[o$i];"
        chain="[o$i]"
        i=$((i + 1))
    done
    ffmpeg -loglevel error -y "${inputs[@]}" -filter_complex "${filters%;}" \
        -map "$chain" -frames:v 1 "$image"
}

args=(-n -e -f -c "$FALLBACK_COLOR")
if [ -f "$wallpaper" ] && [ -n "$screen" ] && command -v ffmpeg >/dev/null; then
    [ -f "$image" ] || build_image
    [ -f "$image" ] && args+=(-i "$image")
fi

# Pausar música y notificaciones mientras está bloqueado
command -v playerctl >/dev/null && playerctl -a pause 2>/dev/null
command -v dunstctl  >/dev/null && dunstctl set-paused true

i3lock "${args[@]}"

command -v dunstctl >/dev/null && dunstctl set-paused false
