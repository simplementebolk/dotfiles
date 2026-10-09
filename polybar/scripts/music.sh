#!/usr/bin/env bash
# Canción actual (Spotify o cualquier reproductor MPRIS) para Polybar.
# Se usa con `tail = true`: playerctl avisa de cada cambio, sin sondear.

command -v playerctl >/dev/null || exit 0

play=$'\U000F040A'   # 󰐊
pause=$'\U000F03E4'  # 󰏤

playerctl --follow metadata --format '{{status}}|{{artist}}|{{title}}' 2>/dev/null |
while IFS='|' read -r status artist title; do
    case "$status" in
        Playing) icon="%{F#f0b44c}%{T3}$play%{T-}%{F-}" ;;
        Paused)  icon="%{F#6c7086}%{T3}$pause%{T-}%{F-}" ;;
        *)       echo ""; continue ;;
    esac
    text="${artist:+$artist - }$title"
    [ ${#text} -gt 40 ] && text="${text:0:39}…"
    echo "$icon $text"
done
