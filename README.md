# 🐧 Debian BSPWM Dotfiles

![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

Mis archivos de configuración (*dotfiles*) para un entorno minimalista, fluido y productivo en **Debian Linux** utilizando **BSPWM**, con tema **Catppuccin Mocha** y un color de acento que se adapta al fondo de pantalla.

---

## 📸 Vista Previa

<img width="1920" height="1080" alt="Vista previa del escritorio" src="https://github.com/user-attachments/assets/d4577bbb-72ed-4dff-9476-b5d33b1f74bc" />

---

## ✨ Características

* **Acento automático según el fondo:** al cambiar de fondo (`Super + Shift + b`) se sacan los colores de la imagen y se aplican a la barra, los bordes, Rofi y las notificaciones.
* **Polybar flotante** y translúcida: escritorios en kanji (一 二 三…), música, fecha con calendario, CPU, temperatura, RAM, volumen, bluetooth y red.
* **Menús de Rofi** con el mismo estilo: lanzador de apps, panel de audio, menú de energía, wifi, bluetooth, portapapeles, emojis, capturas y fondos.
* **picom** con animaciones al abrir, cerrar y reacomodar ventanas, desenfoque y esquinas redondeadas.
* **Pantalla de bloqueo** con el fondo actual desenfocado, que se activa sola tras 30 minutos de inactividad y antes de suspender.
* **Notificaciones** con `dunst` usando el mismo tema.

---

## 🛠️ Componentes del Sistema

| Componente | Software |
| :--- | :--- |
| **Window Manager** | `bspwm` |
| **Daemon de Atajos** | `sxhkd` |
| **Barra de Estado** | `polybar` |
| **Lanzador y menús** | `rofi` |
| **Terminal** | `alacritty` |
| **Compositor Visual** | `picom` (v12 o superior, para las animaciones) |
| **Notificaciones** | `dunst` |
| **Fondo de pantalla** | `nitrogen` |
| **Bloqueo de pantalla** | `i3lock` + `xss-lock` |
| **Capturas** | `scrot` (menú) y `ksnip` (editor) |
| **Audio** | PipeWire (`wpctl`) |
| **Calendario** | `yad` |

---

## ⚙️ Instalación paso a paso

> Probado en **Debian 13 (trixie)**. Debian 12 trae una versión de picom sin animaciones; todo lo demás funciona igual.

### 1. Instalar los paquetes

```bash
sudo apt update && sudo apt install -y \
  bspwm sxhkd polybar rofi picom alacritty \
  dunst libnotify-bin nitrogen \
  i3lock xss-lock \
  scrot ksnip xclip xdotool \
  yad playerctl pavucontrol pulsemixer \
  pipewire-pulse wireplumber alsa-utils brightnessctl \
  network-manager bluez \
  ffmpeg jq python3 \
  x11-xserver-utils x11-utils x11-xkb-utils \
  fonts-noto-cjk fonts-noto-color-emoji \
  git wget unzip
```

<details>
<summary>¿Para qué sirve cada paquete?</summary>

| Paquete | Uso |
| :--- | :--- |
| `dunst`, `libnotify-bin` | Notificaciones (`notify-send`) |
| `i3lock`, `xss-lock` | Bloqueo de pantalla manual y automático |
| `scrot`, `ksnip` | Capturas: menú propio y editor |
| `xclip` | Historial del portapapeles y copiar capturas |
| `xdotool` | Escribir emojis y posicionar el calendario |
| `yad` | Calendario al hacer clic en la fecha |
| `playerctl` | Módulo de música (Spotify, Firefox, etc.) |
| `pavucontrol`, `pulsemixer` | Audio avanzado y teclas de volumen |
| `pipewire-pulse`, `wireplumber` | Servidor de audio (`wpctl`) |
| `network-manager`, `bluez` | Menús de wifi y bluetooth |
| `ffmpeg`, `jq`, `python3` | Miniaturas, fondo de bloqueo, panel de audio y acento automático |
| `x11-*-utils` | `xrandr`, `xset`, `xsetroot`, `xdpyinfo`, `setxkbmap` |
| `fonts-noto-cjk` | Escritorios en kanji (一 二 三…) |
| `fonts-noto-color-emoji` | Selector de emojis |

</details>

### 2. Instalar las fuentes Nerd Font

La barra y los menús usan **FiraCode Nerd Font**; la terminal usa **MesloLGS Nerd Font**:

```bash
mkdir -p ~/.local/share/fonts && cd /tmp
for font in FiraCode Meslo; do
  wget -q "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip"
  unzip -o -q "$font.zip" -d ~/.local/share/fonts/"$font"
done
fc-cache -f
```

### 3. Clonar el repositorio

```bash
git clone https://github.com/simplementebolk/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 4. Copiar las configuraciones

> ⚠️ Esto **reemplaza** tus configuraciones actuales de estos programas. Si quieres conservarlas, respáldalas antes.

```bash
mkdir -p ~/.config
cp -r alacritty bspwm dunst gtk-3.0 gtk-4.0 picom polybar rice rofi sxhkd ~/.config/

# Permisos de ejecución
chmod +x ~/.config/bspwm/bspwmrc ~/.config/sxhkd/sxhkdrc ~/.config/polybar/launch.sh \
  ~/.config/bspwm/scripts/*.sh ~/.config/polybar/scripts/*.sh \
  ~/.config/rice/*.sh ~/.config/rice/*.py
```

### 5. Ajustar los monitores

En `~/.config/bspwm/bspwmrc` los monitores están configurados para mi equipo (`DP-4` a la izquierda a 180 Hz y `HDMI-0` a la derecha). Revisa los nombres de los tuyos con:

```bash
xrandr --query | grep " connected"
```

y cambia estas líneas según tu configuración:

```bash
xrandr --output DP-4   --mode 1920x1080 --rate 180 --pos 0x0    --primary \
       --output HDMI-0 --mode 1920x1080 --rate 60  --pos 1920x0

bspc wm -O DP-4 HDMI-0
bspc monitor DP-4 -d 一 二 三 四 五
bspc monitor HDMI-0 -d 六 七 八 九 十
```

Con un solo monitor, deja solo uno con los diez escritorios: `bspc monitor <NOMBRE> -d 一 二 三 四 五 六 七 八 九 十`.

### 6. Agregar fondos de pantalla

El selector de fondos busca imágenes (`.jpg`, `.png`, `.webp`) en `~/Downloads/Wallpapers`:

```bash
mkdir -p ~/Downloads/Wallpapers
# copia ahí tus fondos
```

Para usar otra carpeta, define `WALL_DIR` (por ejemplo en `~/.profile`): `export WALL_DIR="$HOME/Pictures/Wallpapers"`.

### 7. Iniciar sesión

Cierra sesión y en la pantalla de inicio elige la sesión **bspwm**. Una vez dentro, pulsa `Super + Shift + b` para elegir un fondo y su color de acento.

---

## ⌨️ Atajos de Teclado (`sxhkd`)

### 🚀 Sistema y Aplicaciones
| Atajo | Acción |
| :--- | :--- |
| `Super + Enter` | Abrir terminal (**Alacritty**) |
| `Super + d` | Lanzador de aplicaciones (**Rofi**) |
| `Super + x` | Bloquear pantalla |
| `Super + Shift + e` | Menú de energía (bloquear, cerrar sesión, reiniciar, apagar) |
| `Super + v` | Historial del portapapeles |
| `Super + e` | Selector de emojis |
| `Super + Shift + b` | Selector de fondos con acento automático |
| `Super + Escape` | Recargar la configuración de `sxhkd` |
| `Super + Alt + r` | Reiniciar BSPWM |
| `Super + Alt + q` | Salir de BSPWM |

### 📸 Capturas de Pantalla
| Atajo | Acción |
| :--- | :--- |
| `Super + Shift + s` | Menú de capturas: completa, monitor, región o ventana, ventana activa, con retraso de 5 s |
| `Print` | Capturar el monitor activo con el editor (**ksnip**) |
| `Shift + Print` | Capturar una región con el editor (**ksnip**) |

Las capturas del menú se guardan en `~/Pictures/Screenshots` y se copian al portapapeles.

### 🪟 Gestión de Ventanas
| Atajo | Acción |
| :--- | :--- |
| `Super + w` | Cerrar ventana actual |
| `Super + Shift + w` | Forzar cierre de ventana (*kill*) |
| `Super + {h, j, k, l}` | Mover el foco (izquierda, abajo, arriba, derecha) |
| `Super + Shift + {h, j, k, l}` | Intercambiar la ventana de posición |
| `Super + Alt + {h, j, k, l}` | Agrandar la ventana hacia ese lado |
| `Super + Alt + Shift + {h, j, k, l}` | Achicar la ventana desde ese lado |
| `Super + t` | Modo enlosado (*tiled*) |
| `Super + Shift + t` | Modo pseudo-enlosado (*pseudo tiled*) |
| `Super + s` | Modo flotante (*floating*) |
| `Super + f` | Pantalla completa (*fullscreen*) |
| `Super + m` | Alternar entre *tiled* y *monocle* |
| `Super + g` | Intercambiar con la ventana más grande |

### 🖥️ Escritorios y Monitores
| Atajo | Acción |
| :--- | :--- |
| `Super + {1-9, 0}` | Ir al escritorio 1 al 10 |
| `Super + Shift + {1-9, 0}` | Mover la ventana al escritorio 1 al 10 |
| `Super + Tab` | Volver al último escritorio |
| `Super + {coma, punto}` | Cambiar el foco al monitor anterior / siguiente |
| `Super + Shift + {coma, punto}` | Mover la ventana al otro monitor |

### 🔊 Multimedia
| Atajo | Acción |
| :--- | :--- |
| `F1` | Silenciar / activar sonido |
| `F2` / `F3` | Bajar / subir volumen (10%) |
| `F4` | Silenciar / activar micrófono |
| `F5` / `F6` | Bajar / subir brillo (5%) |

---

## 🖱️ Clics en la Barra

| Módulo | Clic izquierdo | Clic derecho | Rueda |
| :--- | :--- | :--- | :--- |
| Logo de Debian | Lanzador de apps | Menú de energía | — |
| Música | Pausar / reanudar | Siguiente canción | Anterior / siguiente |
| Fecha | Calendario | — | — |
| Volumen | Panel de audio (salidas, micrófono, volumen) | Silenciar | Subir / bajar volumen |
| Bluetooth | Menú de bluetooth | — | — |
| Red | Menú de wifi | — | — |

En el **panel de audio**, las flechas `←` / `→` cambian el volumen y un clic en una salida o micrófono la activa.

---

## 🎨 Color de Acento

El acento actual se guarda en `~/.config/rice/accent`. Se puede cambiar de tres formas:

* **Con el selector de fondos** (`Super + Shift + b`): después de elegir el fondo te ofrece hasta 5 acentos sacados de la imagen.
* **A mano**, con dos colores (acento y secundario):
  ```bash
  ~/.config/rice/set-accent.sh "#e5484d" "#f0b44c"
  ```
* **Ver el actual:** `~/.config/rice/set-accent.sh`

El cambio se aplica al instante en bspwm, Polybar, Rofi y dunst.

---

## 📁 Estructura

```
├── alacritty/        Terminal (Catppuccin Mocha)
├── bspwm/
│   ├── bspwmrc       Monitores, colores, reglas y programas de inicio
│   └── scripts/      Menús: energía, bloqueo, fondos, capturas, emojis,
│                     portapapeles, wifi, bluetooth y calendario
├── dunst/            Notificaciones
├── gtk-3.0, gtk-4.0/ Tema oscuro para apps GTK
├── picom/            Animaciones, desenfoque, sombras y esquinas
├── polybar/
│   ├── config.ini    Barra y módulos
│   └── scripts/      Música, red, temperatura y panel de audio
├── rice/             Acento automático (set-accent.sh, wallcolor.py)
├── rofi/             Tema principal y temas de cada menú
└── sxhkd/            Atajos de teclado
```
