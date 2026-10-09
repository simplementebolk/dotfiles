#!/usr/bin/env bash
# Menú wifi con Rofi usando NetworkManager (nmcli).

lock=$'\U000F033E'     # 󰌾 red protegida
open=$'\U000F0FC6'     # 󰿆 red abierta
on=$'\U000F05A9'       # 󰖩
off=$'\U000F05AA'      # 󰖪

notify() { command -v notify-send >/dev/null && notify-send -a Wi-Fi -i network-wireless "$@"; }

if [ "$(nmcli radio wifi)" = "enabled" ]; then
    toggle="$off  Desactivar Wi-Fi"
    # IN-USE:SECURITY:SIGNAL:SSID (el SSID al final porque puede contener ":")
    # Ordenadas por señal, sin SSID repetidos ni redes ocultas
    networks=$(nmcli -t -e no -f IN-USE,SECURITY,SIGNAL,SSID device wifi list --rescan auto |
        sort -t: -k3,3nr | awk -F: '{ ssid = $0; sub(/^([^:]*:){3}/, "", ssid) }
            ssid != "" && !seen[ssid]++ { print $1 ":" $2 ":" $3 ":" ssid }')
else
    toggle="$on  Activar Wi-Fi"
    networks=""
fi

# Línea visible: "󰌾  MiRed (78%) ✓"
menu=$(while IFS=: read -r inuse security signal ssid; do
    [ -z "$ssid" ] && continue
    icon=$open; [ -n "$security" ] && icon=$lock
    mark=""; [ "$inuse" = "*" ] && mark=" ✓"
    printf '%s  %s (%s%%)%s\n' "$icon" "$ssid" "$signal" "$mark"
done <<< "$networks")

chosen=$(printf '%s\n%s' "$toggle" "$menu" | sed '/^$/d' |
    rofi -dmenu -i -format i -selected-row 1 -p "  Wi-Fi")
[ -z "$chosen" ] && exit 0

if [ "$chosen" = 0 ]; then
    if [[ $toggle == *Desactivar* ]]; then nmcli radio wifi off; else nmcli radio wifi on; fi
    exit 0
fi

line=$(sed -n "${chosen}p" <<< "$networks")
security=$(cut -d: -f2 <<< "$line")
ssid=$(cut -d: -f4- <<< "$line")

# Si ya existe una conexión guardada con ese nombre, solo se activa
if nmcli -g NAME connection show | grep -Fxq "$ssid"; then
    result=$(nmcli connection up id "$ssid" 2>&1)
elif [ -n "$security" ]; then
    password=$(rofi -dmenu -password -p "  Contraseña de $ssid")
    [ -z "$password" ] && exit 0
    result=$(nmcli device wifi connect "$ssid" password "$password" 2>&1)
else
    result=$(nmcli device wifi connect "$ssid" 2>&1)
fi

if [[ $result == *successfully* ]]; then
    notify "Conectado" "Ahora estás conectado a \"$ssid\"."
else
    notify -u critical "No se pudo conectar" "$result"
fi
