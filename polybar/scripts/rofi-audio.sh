#!/usr/bin/env bash

# Obtener volumen y estado actual de forma segura
vol=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\d+%' | head -n 1)
[ -z "$vol" ] && vol="N/A"

mute=$(pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null | awk '{print $2}')
if [ "$mute" = "yes" ]; then
    mute_label="󰝟 Mute (Desactivar silencio)"
else
    mute_label="󰝟 Mute (Activar silencio)"
fi

# Lista de opciones en orden exacto
options="$mute_label\n󰕾 Subir Volumen (+10%)\n󰖀 Bajar Volumen (-10%)\n󰓃 Cambiar Salida de Audio\n󰍬 Cambiar Micrófono\n󰨇 Pavucontrol (Avanzado)"

# '-format i' hace que Rofi devuelva solo el número de índice (0, 1, 2...)
chosen=$(echo -e "$options" | rofi -dmenu -i -format i -p "Audio ($vol)")

# Si presionas ESC o cierras el menú, sale inmediatamente
[ -z "$chosen" ] && exit 0

case "$chosen" in
    0)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    1)
        pactl set-sink-volume @DEFAULT_SINK@ +10%
        ;;
    2)
        pactl set-sink-volume @DEFAULT_SINK@ -10%
        ;;
    3)
        # Menú de Dispositivos de Salida
        sinks=$(pactl list sinks | awk '/Name:/ {name=$2} /Description:/ {sub(/.*Description: /, ""); print $0 " -> " name}')
        if [ -n "$sinks" ]; then
            selected_sink=$(echo "$sinks" | awk -F " -> " '{print $1}' | rofi -dmenu -i -p "Salida de audio:")
            if [ -n "$selected_sink" ]; then
                sink_id=$(echo "$sinks" | grep "^$selected_sink" | awk -F " -> " '{print $2}')
                pactl set-default-sink "$sink_id"
                pactl list sink-inputs short | awk '{print $1}' | while read -r stream; do
                    pactl move-sink-input "$stream" "$sink_id" 2>/dev/null
                done
                notify-send "Audio" "Salida: $selected_sink"
            fi
        fi
        ;;
    4)
        # Menú de Micrófonos
        sources=$(pactl list sources | grep -v "monitor" | awk '/Name:/ {name=$2} /Description:/ {sub(/.*Description: /, ""); print $0 " -> " name}')
        if [ -n "$sources" ]; then
            selected_source=$(echo "$sources" | awk -F " -> " '{print $1}' | rofi -dmenu -i -p "Micrófono:")
            if [ -n "$selected_source" ]; then
                source_id=$(echo "$sources" | grep "^$selected_source" | awk -F " -> " '{print $2}')
                pactl set-default-source "$source_id"
                notify-send "Audio" "Entrada: $selected_source"
            fi
        fi
        ;;
    5)
        pavucontrol &
        ;;
esac
