#!/usr/bin/env bash
# Menú del historial del portapapeles (Rofi).
# Enter: copiar  ·  Shift+Supr: borrar la entrada  ·  Alt+Supr: borrar todo

DIR="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist"
notify() { command -v notify-send >/dev/null && notify-send -a Portapapeles "$@"; }

if ! command -v xclip >/dev/null; then
    notify -u critical "Falta xclip" "sudo apt install xclip"
    exit 1
fi
pgrep -f 'bspwm/scripts/clipd.sh' >/dev/null ||
    (setsid "$HOME/.config/bspwm/scripts/clipd.sh" >/dev/null 2>&1 &)

while true; do
    mapfile -t files < <(ls -1t "$DIR" 2>/dev/null)
    if [ ${#files[@]} -eq 0 ]; then
        notify "Historial vacío" "Copia algo de texto y vuelve a abrirlo."
        exit 0
    fi

    # Vista previa de una línea: saltos de línea como ⏎, máximo 90 caracteres
    preview() {
        local f
        for f in "${files[@]}"; do
            head -c 400 "$DIR/$f" | tr '\n\t' '⏎ ' | sed 's/  */ /g; s/^ //' | cut -c1-90
            echo
        done
    }

    choice=$(preview | rofi -dmenu -i -no-custom -format i -p "󰅌  Portapapeles" \
        -mesg "<span size='small'>Enter copiar · Shift+Supr borrar · Alt+Supr borrar todo</span>" \
        -kb-custom-1 'Shift+Delete' -kb-custom-2 'Alt+Delete' \
        -me-select-entry '' -me-accept-entry MousePrimary)
    code=$?
    [ -z "$choice" ] && [ $code -ne 11 ] && exit 0

    case $code in
        0)  xclip -selection clipboard -i < "$DIR/${files[$choice]}"
            touch "$DIR/${files[$choice]}"
            exit 0 ;;
        10) rm -f "$DIR/${files[$choice]}" ;;   # borrar entrada y volver al menú
        11) rm -f "$DIR"/*; notify "Historial borrado"; exit 0 ;;
        *)  exit 0 ;;
    esac
done
