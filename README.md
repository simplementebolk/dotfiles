# 🐧 Debian BSPWM Dotfiles

![Debian](https://img.shields.io/badge/Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)

Mis archivos de configuración (*dotfiles*) para un entorno minimalista, fluido y productivo en **Debian Linux** utilizando **BSPWM**.

---

## 📸 Vista Previa (Screenshots)

Desktop Preview<img width="3840" height="1080" alt="2026-08-12-212331" src="https://github.com/user-attachments/assets/15cfcea8-09d7-4eb7-a2ef-635d9c6dc67e" />

<img width="1920" height="1080" alt="2026-09-02_09-56" src="https://github.com/user-attachments/assets/b9118f94-8395-4da1-8772-c020d11bfd2b" />



---

## 🛠️ Componentes del Sistema

| Componente | Software |
| :--- | :--- |
| **Window Manager** | `bspwm` |
| **Daemon de Atajos** | `sxhkd` |
| **Barra de Estado** | `polybar` |
| **Lanzador de Apps** | `rofi` |
| **Terminal** | `alacritty` |
| **Compositor Visual** | `picom` |
| **Fondo de pantalla** | `nitrogen` |
| **Capturas** | `ksnip` |

---

## 🎨 Tema

Todo el entorno usa la paleta **[Catppuccin Mocha](https://catppuccin.com/palette)**:

* **Polybar** flotante y translúcida, alineada con los *gaps* de las ventanas, con iconos de colores por módulo.
* **Rofi** con tema Catppuccin propio (también lo usan los menús de wifi, bluetooth y audio).
* **picom** con desenfoque `dual_kawase`, esquinas redondeadas, sombras suaves y animaciones de aparición.
* **bspwm** con borde malva (`#cba6f7`) en la ventana activa.
* **GTK** en modo oscuro (`Adwaita-dark`).

**Fuentes necesarias:** `FiraCode Nerd Font`, `MesloLGS Nerd Font` y `Noto Sans CJK` (para los escritorios 一 二 三…).

---

## ⚙️ Requisitos e Instalación

### 1. Actualizar el sistema e instalar dependencias

Abre la terminal e instala los paquetes necesarios en **Debian**:

```bash
sudo apt update && sudo apt install -y \
  bspwm \
  sxhkd \
  alacritty \
  rofi \
  picom \
  polybar \
  git \
  scrot \
  brightnessctl \
  pulsemixer \
  alsa-utils \
  nitrogen \
  ksnip \
  fonts-noto-cjk
```

### 2. Clonar el repositorio

```bash
git clone https://github.com/simplementebolk/dotfiles.git ~/dotfiles
cd ~/dotfiles
```
### 3. Copiar configuraciones y asignar permisos
Ejecuta estos comandos para copiar todas las carpetas a tu directorio `~/.config/` y asignar los permisos necesarios:

```bash
# Crear la carpeta .config si no existe y copiar los archivos
mkdir -p ~/.config && cp -r alacritty bspwm gtk-3.0 picom polybar rofi sxhkd ~/.config/

# Dar permisos de ejecución a los scripts
chmod +x ~/.config/bspwm/bspwmrc ~/.config/sxhkd/sxhkdrc ~/.config/polybar/launch.sh \
  ~/.config/bspwm/scripts/*.sh ~/.config/polybar/scripts/*.sh
```

### 4. ⌨️ Atajos de Teclado (`sxhkd`)

### 🚀 Sistema y Aplicaciones
* `Super + Enter` ➔ Abrir terminal (**Alacritty**)
* `Super + d` ➔ Lanzador de aplicaciones (**Rofi**)
* `Super + l` ➔ Bloquear pantalla (**Betterlockscreen**)
* `Super + Escape` ➔ Recargar la configuración de `sxhkd`
* `Super + Alt + r` ➔ Reiniciar BSPWM
* `Super + Alt + q` ➔ Salir de BSPWM

### 🪟 Gestión de Ventanas
* `Super + w` ➔ Cerrar ventana actual
* `Super + Shift + w` ➔ Forzar cierre de ventana (*kill*)
* `Super + {h, j, k, l}` ➔ Mover foco (Izquierda, Abajo, Arriba, Derecha)
* `Super + Shift + {h, j, k, l}` ➔ Intercambiar ventana de posición
* `Super + t` ➔ Modo enlosado (*Tiled*)
* `Super + Shift + t` ➔ Modo pseudo-enlosado (*Pseudo Tiled*)
* `Super + s` ➔ Modo flotante (*Floating*)
* `Super + f` ➔ Modo pantalla completa (*Fullscreen*)
* `Super + m` ➔ Alternar entre modo *Tiled* y *Monocle*

### 🔢 Áreas de Trabajo (Desktops)
* `Super + {1-9, 0}` ➔ Cambiar a la área de trabajo (1 al 10)
* `Super + Shift + {1-9, 0}` ➔ Mover ventana a la área de trabajo (1 al 10)

### 🔊 Multimedia y Controles
* `F1` ➔ Silenciar / Activar sonido (**Pulsemixer**)
* `F2` / `F3` ➔ Bajar / Subir volumen (-10% / +10%)
* `F4` ➔ Silenciar / Activar micrófono
* `F5` / `F6` ➔ Bajar / Subir brillo de pantalla (-5% / +5%)
* `Print` ➔ Captura del monitor activo (**ksnip**)
* `Shift + Print` ➔ Captura de una región seleccionada (**ksnip**)
