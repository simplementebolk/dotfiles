#!/bin/bash

# Obtener el estado de la batería BAT0
battery0_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
battery0_percentage=$(echo "$battery0_info" | grep "percentage:" | awk '{print $2}' | tr -d '%')
battery0_status=$(echo "$battery0_info" | grep "state:" | awk '{print $2}')

# Obtener el estado de la batería BAT1
battery1_info=$(upower -i /org/freedesktop/UPower/devices/battery_BAT1)
battery1_percentage=$(echo "$battery1_info" | grep "percentage:" | awk '{print $2}' | tr -d '%')
battery1_status=$(echo "$battery1_info" | grep "state:" | awk '{print $2}')

# Calcular el porcentaje combinado (promedio simple)
combined_percentage=$(echo "($battery0_percentage + $battery1_percentage) / 2" | bc)

# Determinar el icono según el porcentaje combinado y el estado de carga
if [[ "$battery0_status" == "charging" || "$battery1_status" == "charging" ]]; then
    # Si alguna batería está cargando
    icon=""  # Icono de carga
elif [ "$combined_percentage" -ge 90 ]; then
    icon=""  # Batería llena
elif [ "$combined_percentage" -ge 60 ]; then
    icon=""  # Batería en buen estado
elif [ "$combined_percentage" -ge 30 ]; then
    icon=""  # Batería baja
else
    icon=""  # Batería muy baja
fi

# Mostrar el icono y el porcentaje combinado
echo "$icon $combined_percentage%"
