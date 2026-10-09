#!/usr/bin/env bash
# Temperatura del CPU para Polybar, con color según el nivel.
# Lee directamente de /sys (más liviano que llamar a `sensors`).

icon=$'\U000F050F'  # 󰔏

read_temp() {
    local hw label
    # Intel (coretemp: "Package id 0") o AMD (k10temp: "Tctl")
    for hw in /sys/class/hwmon/hwmon*; do
        case "$(cat "$hw/name" 2>/dev/null)" in
            coretemp|k10temp|zenpower)
                for label in "$hw"/temp*_label; do
                    case "$(cat "$label")" in
                        "Package id 0"|Tctl|Tdie)
                            echo $(( $(cat "${label%_label}_input") / 1000 ))
                            return
                            ;;
                    esac
                done
                ;;
        esac
    done
    # Respaldo genérico
    [ -r /sys/class/thermal/thermal_zone0/temp ] &&
        echo $(( $(cat /sys/class/thermal/thermal_zone0/temp) / 1000 ))
}

temp=$(read_temp)
[ -z "$temp" ] && exit 0

if   [ "$temp" -ge 80 ]; then color="#e5484d"  # rojo
elif [ "$temp" -ge 65 ]; then color="#f0b44c"  # dorado
else                          color="#a6adc8"  # normal
fi

echo "%{F$color}%{T3}$icon%{T-}%{F-} ${temp}°C"
