#!/usr/bin/env bash

# Busca una interfaz con conexión activa
iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1); exit}')

case "$iface" in
    eth*|en*)
        echo "󰈀 " # Ethernet conectado
        ;;
    wlan*|wlp*)
        if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
            echo "󰤨 " # Wi-Fi con internet
        else
            echo "󰤭 " # Wi-Fi sin internet
        fi
        ;;
    *)
        echo "󰤭 " # Sin conexión
        ;;
esac

