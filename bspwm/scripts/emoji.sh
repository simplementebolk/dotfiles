#!/usr/bin/env bash
# Selector de emojis (Rofi). El elegido se escribe en la ventana activa y
# queda copiado en el portapapeles. Los usados recientemente salen primero.

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}"
LIST="$CACHE/rice-emoji.txt"
RECENT="$CACHE/rice-emoji-recent.txt"

# Lista generada una vez desde la base Unicode de Python ("😀 grinning face")
if [ ! -s "$LIST" ]; then
    python3 -I - > "$LIST" <<'PY'
import unicodedata
ranges = [(0x1F600, 0x1F64F), (0x1F900, 0x1F9FF), (0x1FA70, 0x1FAFF),
          (0x1F300, 0x1F5FF), (0x1F680, 0x1F6FF), (0x2600, 0x26FF), (0x2700, 0x27BF)]
for lo, hi in ranges:
    for cp in range(lo, hi + 1):
        ch = chr(cp)
        if unicodedata.category(ch) != "So":
            continue
        try:
            name = unicodedata.name(ch).lower()
        except ValueError:
            continue
        # Los símbolos antiguos (2600-27BF) se fuerzan a versión emoji
        if cp < 0x1F000:
            ch += "️"
        print(f"{ch} {name}")
PY
fi

touch "$RECENT"
choice=$( { cat "$RECENT"; grep -vxFf "$RECENT" "$LIST"; } |
    rofi -dmenu -i -no-custom -p "󰞅  Emoji" \
        -theme-str 'window { width: 520px; } listview { lines: 10; } element-text { font: "FiraCode Nerd Font 12"; }' \
        -me-select-entry '' -me-accept-entry MousePrimary)
[ -z "$choice" ] && exit 0
emoji=${choice%% *}

# Recientes: el elegido arriba, máximo 20
{ echo "$choice"; grep -vxF "$choice" "$RECENT"; } | head -n 20 > "$RECENT.tmp" && mv "$RECENT.tmp" "$RECENT"

command -v xclip >/dev/null && printf '%s' "$emoji" | xclip -selection clipboard
sleep 0.15   # dejar que Rofi devuelva el foco a la ventana
xdotool type --clearmodifiers -- "$emoji"
