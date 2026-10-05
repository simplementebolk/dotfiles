#!/bin/bash

# Extraer la temperatura y tomar solo la parte entera del número para evitar parpadeos
raw_temp=$(sensors 2>/dev/null | grep -E 'Package id 0|Core 0|Tctl|temp1' | grep -oE '\+[0-9]+' | head -n1 | tr -d '+')

# Si sensors no devuelve datos, consultar sysfs
if [ -z "$raw_temp" ]; then
    sys_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null)
    if [ -n "$sys_temp" ]; then
        raw_temp=$((sys_temp / 1000))
    fi
fi

# Si no hay lectura, mostrar N/A
if [ -z "$raw_temp" ]; then
    echo "CPU: N/A"
    exit 0
fi

# Asignar un indicador de texto o símbolo compatible
if [ "$raw_temp" -ge 80 ]; (
    status="[HOT]"
elif [ "$raw_temp" -ge 60 ]; then
    status="[MID]"
else
    status="[OK]"
fi

# Salida limpia en números enteros (Ejemplo: CPU: 40°C)
echo "CPU: ${raw_temp}°C"
