#!/usr/bin/env bash
# Demonio del historial del portapapeles (solo texto).
# Revisa el portapapeles cada medio segundo y guarda cada texto nuevo en
# ~/.cache/cliphist (un archivo por entrada, el más reciente es el más nuevo).
# No guarda lo que copian los gestores de contraseñas (KeePassXC, etc.).

DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist"
MAX=50                 # entradas guardadas
MAX_BYTES=200000       # no guardar textos gigantes

command -v xclip >/dev/null || { echo "clipd: falta xclip" >&2; exit 1; }
mkdir -p "$DIR" && chmod 700 "$DIR"

last=""
while sleep 0.5; do
    targets=$(xclip -selection clipboard -o -t TARGETS 2>/dev/null) || continue
    # Solo texto, y nunca contraseñas marcadas por el gestor
    grep -qx 'UTF8_STRING\|STRING\|text/plain.*' <<< "$targets" || continue
    grep -q 'x-kde-passwordManagerHint' <<< "$targets" && continue

    sum=$(xclip -selection clipboard -o 2>/dev/null | head -c "$MAX_BYTES" | md5sum | cut -c1-32)
    [ "$sum" = "$last" ] && continue
    last=$sum

    file="$DIR/$sum"
    if [ -f "$file" ]; then
        touch "$file"   # ya existía: pasa a ser la más reciente
    else
        xclip -selection clipboard -o 2>/dev/null | head -c "$MAX_BYTES" > "$file"
        # Ignorar textos vacíos o solo espacios
        if ! grep -q '[^[:space:]]' "$file"; then rm -f "$file"; continue; fi
    fi
    # Mantener solo las MAX más recientes
    ls -1t "$DIR" | tail -n +$((MAX + 1)) | while read -r old; do rm -f "$DIR/$old"; done
done
