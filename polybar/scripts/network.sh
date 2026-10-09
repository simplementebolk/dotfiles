#!/usr/bin/env bash
# Estado de la red para Polybar (ethernet / wifi), sin hacer ping.

eth=$'\U000F0200'       # 󰈀
eth_off=$'\U000F0202'   # 󰈂
wifi_off=$'\U000F092E'  # 󰤮
wifi_ramp=($'\U000F091F' $'\U000F0922' $'\U000F0925' $'\U000F0928')  # 󰤟 󰤢 󰤥 󰤨

# Interfaz que se usa para salir a internet
iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for (i = 1; i < NF; i++) if ($i == "dev") { print $(i + 1); exit }}')

if [ -z "$iface" ]; then
    echo "%{F#e5484d}%{T3}$eth_off%{T-}%{F-} Sin red"
    exit 0
fi

if [ -d "/sys/class/net/$iface/wireless" ]; then
    # Formato: ACTIVE:SIGNAL:SSID (el SSID va al final porque puede contener ":")
    info=$(nmcli -t -e no -f ACTIVE,SIGNAL,SSID device wifi list --rescan no 2>/dev/null | grep -m1 '^yes:')
    signal=$(cut -d: -f2 <<< "$info")
    ssid=$(cut -d: -f3- <<< "$info")
    if [ -z "$ssid" ]; then
        echo "%{F#e5484d}%{T3}$wifi_off%{T-}%{F-}"
        exit 0
    fi
    level=$(( ${signal:-0} / 26 ))  # 0..3
    echo "%{F#a6adc8}%{T3}${wifi_ramp[$level]}%{T-}%{F-} ${ssid:0:20}"
else
    echo "%{F#a6adc8}%{T3}$eth%{T-}%{F-}"
fi
