#!/usr/bin/env bash
# Panel de audio con Rofi + PipeWire (wpctl).
# Clic en una salida o micrófono para usarlo. ←/→ cambian el volumen.
# El panel se queda abierto hasta pulsar Esc o hacer clic fuera.

SINK=@DEFAULT_AUDIO_SINK@
SOURCE=@DEFAULT_AUDIO_SOURCE@
THEME="$HOME/.config/rofi/audio.rasi"

# Colores Catppuccin Mocha
ACCENT="#e5484d"; TEAL="#f0b44c"; GREEN="#f0b44c"; RED="#e5484d"
DIM="#6c7086"; TRACK="#45475a"

# Iconos (Nerd Font)
I_SPEAKER=$'\U000F04C3'; I_MONITOR=$'\U000F0379'; I_HEADPHONES=$'\U000F02CB'
I_MIC=$'\U000F036C'; I_MIC_OFF=$'\U000F036D'
I_VOL=$'\U000F057E'; I_VOL_OFF=$'\U000F075F'
I_UP=$'\U000F075D'; I_DOWN=$'\U000F075E'; I_GEAR=$'\U000F0493'
DOT=$'\U000F0765'  # 󰝥

notify() { command -v notify-send >/dev/null && notify-send -a Audio -i audio-card "$@"; }
escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' <<< "$1"; }

# "Volume: 0.45 [MUTED]" -> "45 1"
read_volume() {
    wpctl get-volume "$1" 2>/dev/null |
        awk '{ printf "%d %d", $2 * 100 + 0.5, /MUTED/ }'
}

# Barra de 16 segmentos: ━━━━━━━━━━━━━━━━
bar() {
    local pct=$1 color=$2 filled empty
    filled=$(( (pct > 100 ? 100 : pct) * 16 / 100 ))
    empty=$(( 16 - filled ))
    printf "<span color='%s'>%s</span><span color='%s'>%s</span>" \
        "$color" "$(printf '━%.0s' $(seq 1 $filled) 2>/dev/null)" \
        "$TRACK" "$(printf '━%.0s' $(seq 1 $empty) 2>/dev/null)"
}

# Dispositivos como "clase<TAB>id<TAB>es_default<TAB>node.name<TAB>descripción<TAB>nick"
list_devices() {
    pw-dump 2>/dev/null | jq -r '
        ([ .[] | select(.type == "PipeWire:Interface:Metadata")
               | select(.props."metadata.name" == "default")
               | .metadata[] | select(.key == "default.audio.sink" or .key == "default.audio.source")
               | .value.name ]) as $defaults
        | .[] | select(.type == "PipeWire:Interface:Node") | .info.props
        | select(."media.class" == "Audio/Sink" or ."media.class" == "Audio/Source")
        | [ ."media.class", ."object.id", (if (."node.name" | IN($defaults[])) then 1 else 0 end),
            ."node.name", (."node.description" // ."node.name"), (."node.nick" // "") ]
        | @tsv'
}

# Nombre amigable + icono según el tipo de dispositivo
describe() {
    local class=$1 name=$2 desc=$3 nick=$4 icon title sub
    case "$name" in
        *hdmi*|*HDMI*|*DisplayPort*)
            icon=$I_MONITOR; sub="HDMI"
            # El nick es el modelo del monitor (ej. C24X5F) salvo que sea genérico
            if [ -n "$nick" ] && [[ $nick != HDA* && $nick != HDMI* && $nick != DP* ]]; then
                title="Monitor $nick"
            else
                title="Monitor (HDMI)"
            fi ;;
        bluez*)
            icon=$I_HEADPHONES; title=$desc; sub="Bluetooth" ;;
        *usb*)
            icon=$I_HEADPHONES; title=$desc; sub="USB" ;;
        *)
            if [ "$class" = "Audio/Source" ]; then
                icon=$I_MIC; title="Micrófono"; sub=${nick:-$desc}
            else
                icon=$I_SPEAKER; title="Parlantes / audífonos"; sub=${nick:-$desc}
            fi ;;
    esac
    [ "$class" = "Audio/Source" ] && [ "$icon" != "$I_MIC" ] && icon=$I_MIC
    printf '%s\t%s\t%s' "$icon" "$(escape "$title")" "$(escape "$sub")"
}

selected=0
while true; do
    read -r vol muted     <<< "$(read_volume $SINK)"
    read -r mic mic_muted <<< "$(read_volume $SOURCE)"

    # ── Mensaje superior: barras de volumen ──
    if [ "$muted" = 1 ]; then
        out_line="<span color='$DIM'>$I_VOL_OFF</span>  <b>Salida   </b> $(bar "$vol" "$DIM")  <span color='$DIM'> off</span>"
    else
        out_line="<span color='$ACCENT'>$I_VOL</span>  <b>Salida   </b> $(bar "$vol" "$ACCENT")  $(printf '%3d%%' "$vol")"
    fi
    if [ -z "$mic" ]; then
        mic_line="<span color='$DIM'>$I_MIC_OFF  Sin micrófono</span>"
    elif [ "$mic_muted" = 1 ]; then
        mic_line="<span color='$DIM'>$I_MIC_OFF</span>  <b>Micrófono</b> $(bar "$mic" "$DIM")  <span color='$DIM'> off</span>"
    else
        mic_line="<span color='$TEAL'>$I_MIC</span>  <b>Micrófono</b> $(bar "$mic" "$TEAL")  $(printf '%3d%%' "$mic")"
    fi
    mesg="$out_line"$'\n'"$mic_line"

    # ── Filas: salidas, micrófonos y acciones ──
    rows=(); actions=(); active=()
    while IFS=$'\t' read -r class id is_default name desc nick; do
        [ -z "$id" ] && continue
        IFS=$'\t' read -r icon title sub <<< "$(describe "$class" "$name" "$desc" "$nick")"
        if [ "$is_default" = 1 ]; then
            mark="  <span color='$GREEN'>$DOT</span>"
            active+=("${#rows[@]}")
            color=$([ "$class" = "Audio/Sink" ] && echo "$ACCENT" || echo "$TEAL")
        else
            mark=""; color=$DIM
        fi
        rows+=("<span color='$color'>$icon</span>  $title  <span size='small' color='$DIM'>$sub</span>$mark")
        actions+=("default:$id:$title")
    done < <(list_devices | sort -t$'\t' -k1,1)  # Salidas primero

    if [ "$muted" = 1 ]; then
        rows+=("<span color='$GREEN'>$I_VOL</span>  Activar sonido")
    else
        rows+=("<span color='$DIM'>$I_VOL_OFF</span>  Silenciar")
    fi
    actions+=("mute-sink")
    rows+=("<span color='$DIM'>$I_UP</span>  Subir volumen  <span size='small' color='$DIM'>→</span>");  actions+=("up")
    rows+=("<span color='$DIM'>$I_DOWN</span>  Bajar volumen  <span size='small' color='$DIM'>←</span>"); actions+=("down")
    if [ -n "$mic" ]; then
        if [ "$mic_muted" = 1 ]; then
            rows+=("<span color='$GREEN'>$I_MIC</span>  Activar micrófono")
        else
            rows+=("<span color='$DIM'>$I_MIC_OFF</span>  Silenciar micrófono")
        fi
        actions+=("mute-source")
    fi
    rows+=("<span color='$DIM'>$I_GEAR</span>  Configuración avanzada"); actions+=("pavucontrol")

    choice=$(printf '%s\n' "${rows[@]}" | rofi -dmenu -theme "$THEME" -markup-rows -no-custom \
        -format i -l "${#rows[@]}" -selected-row "$selected" -mesg "$mesg" \
        -a "$(IFS=,; echo "${active[*]}")" \
        -me-select-entry '' -me-accept-entry MousePrimary \
        -kb-move-char-forward '' -kb-move-char-back '' \
        -kb-custom-1 Right -kb-custom-2 Left)
    code=$?

    case $code in
        10) wpctl set-volume -l 1.0 $SINK 5%+; selected=${choice:-0}; continue ;;
        11) wpctl set-volume $SINK 5%-;        selected=${choice:-0}; continue ;;
        0)  ;;
        *)  exit 0 ;;  # Esc o clic fuera
    esac
    [ -z "$choice" ] && exit 0
    selected=$choice

    case "${actions[$choice]}" in
        default:*)
            rest=${actions[$choice]#default:}
            wpctl set-default "${rest%%:*}"
            notify "Audio" "Ahora usando: ${rest#*:}"
            ;;
        mute-sink)   wpctl set-mute $SINK toggle ;;
        mute-source) wpctl set-mute $SOURCE toggle ;;
        up)          wpctl set-volume -l 1.0 $SINK 5%+ ;;
        down)        wpctl set-volume $SINK 5%- ;;
        pavucontrol) pavucontrol >/dev/null 2>&1 & exit 0 ;;
    esac
done
