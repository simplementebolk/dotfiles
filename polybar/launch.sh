#!/usr/bin/env bash

# Cierra todas las instancias previas de Polybar
killall -q polybar

# Espera a que los procesos de polybar hayan sido destruidos completamente
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Detecta monitores y lanza una instancia de "bar1" para cada uno
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar bar1 2>&1 | tee -a /tmp/polybar-$m.log & disown
  done
else
  polybar bar1 2>&1 | tee -a /tmp/polybar.log & disown
fi

echo "Polybar ejecutada en todos los monitores..."
