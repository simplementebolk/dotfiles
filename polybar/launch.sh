#!/usr/bin/env bash

# Cierra todas las instancias previas de Polybar
killall -q polybar

# Espera a que se cierren (máximo 3 s). Si otra ejecución de este script
# lanzó barras nuevas mientras tanto, no se queda esperando para siempre.
for _ in $(seq 30); do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.1
done
killall -q -9 polybar

# Lanza una barra por cada monitor conectado
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar bar1 >/tmp/polybar-$m.log 2>&1 & disown
  done
else
  polybar bar1 >/tmp/polybar.log 2>&1 & disown
fi

echo "Polybar ejecutada en todos los monitores..."
