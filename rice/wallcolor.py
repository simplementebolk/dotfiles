#!/usr/bin/env python3
"""Saca colores de acento de un fondo de pantalla.

Uso:
    wallcolor.py IMAGEN          -> "#acento #secundario" (la mejor opción)
    wallcolor.py IMAGEN --all    -> una línea "#acento #secundario" por candidato

Reduce la imagen con ffmpeg, agrupa los píxeles con color por tono (ventanas
de 30° para que un color repartido entre tonos vecinos cuente como uno solo)
y devuelve hasta 5 tonos distintos ordenados por presencia. Cada acento lleva
como secundario el siguiente tono de la lista. Los colores se ajustan para
leerse bien sobre fondos oscuros (Catppuccin Mocha).
"""
import colorsys
import math
import subprocess
import sys

W, H = 160, 90
FALLBACK = ("#cba6f7", "#f5c2e7")  # malva/rosa Catppuccin si el fondo es casi gris
MIN_HUE_GAP = 35 / 360
MAX_CANDIDATES = 5


def pixels(path):
    raw = subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-i", path, "-vf", f"scale={W}:{H}",
         "-frames:v", "1", "-f", "rawvideo", "-pix_fmt", "rgb24", "-"],
        capture_output=True, check=True).stdout
    return [tuple(raw[i:i + 3]) for i in range(0, len(raw) - 2, 3)]


def hue_dist(a, b):
    d = abs(a - b) % 1.0
    return min(d, 1.0 - d)


def readable(h, s, l, min_s, max_s):
    # Luminosidad fija para contraste sobre #181825; saturación acotada
    r, g, b = colorsys.hls_to_rgb(h, l, max(min_s, min(max_s, s)))
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def candidates(path):
    px = pixels(path)
    buckets = {}  # tono (36 cubos de 10°) -> [peso, peso*sat, peso*tono_x, peso*tono_y]
    colorful = 0.0
    for r, g, b in px:
        h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        if s < 0.22 or l < 0.15 or l > 0.92:
            continue
        w = s * (1 - abs(l - 0.5) * 0.9)
        colorful += w
        e = buckets.setdefault(int(h * 36) % 36, [0.0, 0.0, 0.0, 0.0])
        # El tono se promedia como vector para no fallar cerca de 0°/360°
        e[0] += w; e[1] += s * w
        e[2] += math.cos(2 * math.pi * h) * w; e[3] += math.sin(2 * math.pi * h) * w

    # Segunda pasada: colores intensos aunque ocupen poco (un templo rojo en
    # un paisaje nevado, los estambres dorados de una flor...)
    vivid = {}  # tono (12 cubos de 30°) -> [n, sat, cos, sin]
    for r, g, b in px:
        h, l, s = colorsys.rgb_to_hls(r / 255, g / 255, b / 255)
        if s >= 0.5 and 0.25 <= l <= 0.8:
            e = vivid.setdefault(int(h * 12) % 12, [0, 0.0, 0.0, 0.0])
            e[0] += 1; e[1] += s
            e[2] += math.cos(2 * math.pi * h); e[3] += math.sin(2 * math.pi * h)
    min_vivid = len(px) * 0.0003  # 0,03 % de la imagen
    vivid_hues = sorted(
        ((e[0], (math.atan2(e[3], e[2]) / (2 * math.pi)) % 1.0, e[1] / e[0])
         for e in vivid.values() if e[0] >= min_vivid), reverse=True)

    # Fondo casi gris y sin nada intenso: solo el acento por defecto
    if colorful / len(px) < 0.04 and not vivid_hues:
        return [FALLBACK[0]], FALLBACK[1]

    windows = []
    for k in range(36):
        acc = [0.0, 0.0, 0.0, 0.0]
        for j in (k - 1, k, k + 1):
            e = buckets.get(j % 36)
            if e:
                for i in range(4):
                    acc[i] += e[i]
        if acc[0] > 0:
            h = (math.atan2(acc[3], acc[2]) / (2 * math.pi)) % 1.0
            windows.append((acc[0], h, acc[1] / acc[0]))
    windows.sort(reverse=True)
    main_hues = [w for w in windows if w[0] >= colorful * 0.03]
    # En fondos casi grises mandan los colores intensos
    if colorful / len(px) < 0.04:
        main_hues = []

    picked = []  # (tono, saturación)
    for _, h, s in main_hues + vivid_hues:
        if all(hue_dist(h, ph) > MIN_HUE_GAP for ph, _ in picked):
            picked.append((h, s))
        if len(picked) == MAX_CANDIDATES:
            break

    accents = [readable(h, s, 0.62, 0.50, 0.80) for h, s in picked]
    # Secundario para el último: un tono análogo
    h, s = picked[-1]
    extra = readable((h + 40 / 360) % 1.0, s, 0.64, 0.45, 0.80)
    return accents, extra


def main():
    path = sys.argv[1]
    accents, extra = candidates(path)
    seconds = accents[1:] + [extra]
    pairs = list(zip(accents, seconds))
    for a, b in (pairs if "--all" in sys.argv else pairs[:1]):
        print(a, b)


if __name__ == "__main__":
    main()
