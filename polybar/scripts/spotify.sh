#!/bin/bash

# Verifica si Spotify está disponible
if playerctl --player=spotify status &>/dev/null; then
    # Verifica si Spotify está reproduciendo música
    if playerctl --player=spotify status | grep -q "Playing"; then
        # Si está reproduciendo, muestra la información
        playerctl --player=spotify metadata --format "{{ artist }} - {{ title }}"
    else
        # Si no está reproduciendo, no muestra nada
        echo ""
    fi
else
    # Si no se encuentra el reproductor, no muestra nada
    echo ""
fi
