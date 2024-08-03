#!/bin/bash

# Obtener una lista de redes disponibles
networks=$(nmcli device wifi list | awk 'NR>1 {print $1}')

# Mostrar las redes en un menú rofi y conectar a la seleccionada
selected=$(echo "$networks" | rofi -dmenu -p "Conectar a:")

# Conectar a la red seleccionada
if [ ! -z "$selected" ]; then
    nmcli device wifi connect "$selected"
fi
