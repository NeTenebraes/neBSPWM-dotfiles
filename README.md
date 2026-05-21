# neBSPWM - Entorno para Ciberseguridad

<div align="center">

![Arch Linux](https://img.shields.io/badge/Arch_Linux-11111b?style=flat&logo=arch-linux&logoColor=f38ba8)
![bspwm](https://img.shields.io/badge/bspwm-1e1e2e?style=flat&logo=bspwm&logoColor=cdd6f4)
![ZSH](https://img.shields.io/badge/ZSH-11111b?style=flat&logo=gnu-bash&logoColor=cba6f7)
![Cybersec Workspace](https://img.shields.io/badge/Cybersecurity-Workspace-bb002f?style=flat&logo=target&logoColor=white)
![Hotkeys Docs](https://img.shields.io/badge/Hotkeys-Docs-313244?style=flat&logo=readthedocs&logoColor=cdd6f4)

</div>

<div align="center">
  
![Catppuccin Mocha](https://img.shields.io/badge/Catppuccin-Mocha-181825?style=flat&logo=linux&logoColor=f38ba8)
![SDDM Astronaut](https://img.shields.io/badge/SDDM-Astronaut%20(Keyitdev)-1e1e2e?style=flat&logo=arch-linux&logoColor=f38ba8)
![Wallpapers](https://img.shields.io/badge/Wallpapers-Timeless_aiart-313244?style=flat&logo=twitter&logoColor=cdd6f4)


</div>

Mi entorno para **ciberseguridad, hacking ético y desarrollo en Linux**.  

**Formateo mi equipo con frecuencia** y quería poder **restaurar mi entorno completo en minutos**, sin tener que volver a configurar cada detalle desde cero. Esta config esta pensada para mi trabajo en un **equipo modesto** (i3 de segunda generación y 8GB de RAM), por lo que diseñé esta configuración pensando en **rendimiento, ligereza y estabilidad**, sin sacrificar la estética ni la comodidad en largas jornadas de trabajo técnico.

El resultado es un entorno minimalista basado en **bspwm**, con **Rofi**, **Polybar**, **Conky**, **Kitty** y una paleta visual **Catppuccin Mocha**, pensado para mantenerse fluido incluso con múltiples herramientas de seguridad abiertas.

![Desktop](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Animated.webp)
> En resumen: **Una configuración que puedes reinstalar rápido, que se siente ágil en hardware antiguo, y que mantiene el mismo “flow” para programar, investigar y crear contenido.**

## ✨ Características

- **Window Manager:** bspwm + sxhkd
- **Display Manager:** SDDM.
- **Launcher:** Rofi (drun mode).
- **Status Bar:** Polybar con módulos de:
  - Administración de sistema (Power menu, workspaces, volumen, System Tray).
  - Detección de Tarjetas de red y su IP local.
  - Colorpicker HEX y RGBA.
  - Nombre de venta activa.
  - Estado de batería.
  - Estado de Firewall y VPN.
- **System Widget:** Conky personalizado:
  - muestra info de sistema, red, almacenamiento y procesos activos
  - incluye panel de **Network & Security** con DNS, uso de red, ping y nombre de tarjeta de red activa.
  - Espacio en disco y unidades externas.
- **Terminal:** Kitty + ZSH + Starship  
- **Lock Screen:** betterlockscreen
- **Themes:** Catppuccin Mocha + Papirus Dark + Nerd Fonts  
- **Screenshots:** Flameshot 

## 🖼️ Screenshots

| Componente | Vista |
|------------|-------|
| Escritorio | ![Main1](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Main1.png) |
| Escritorio | ![Main2](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Main2.png) |
| Rofi | ![Rofi](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Rofi.png) |
| Login Screen | ![SDDM](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/SDDM.png) |

---

## 📦 Requisitos

- Equipo basado en **Arch Linux** (también funciona en derivados como *EndeavourOS* o *Manjaro*).
- `paru` (se instala automáticamente).
- ~2 GB de espacio para dependencias.

**El script instala y configura automáticamente:**
- bspwm, sxhkd, polybar, picom, rofi, dunst, kitty, conky  
- sddm, zsh, starship, neovim, flameshot, betterlockscreen  
- Temas GTK/Qt **Catppuccin Mocha**, íconos **Papirus Dark**, y **Nerd Fonts**

> Apesar se que el script funcione en derivados de arch, se recomienda una **instalación completamente limpia de Archlinux**.

## Instalación

> **Aviso importante:**  
> Antes de ejecutar **cualquier script** en tu sistema, **siempre revisa su contenido**. Nunca ejecutes comandos sin verificar su origen.  
```
git clone https://github.com/NeTenebraes/neBSPWM-dotfiles.git
cd neBSPWM-dotfiles
./setup.sh
```
**Reiniciar:** `systemctl reboot`

> El script requiere que no estés en una TTY para instalar todo lo necesario. En caso de ejecutarlo en una TTY deberás ejecutar el setup.sh dos veces. (La 1ra vez dentro de la TTY y luego dentro de BSPWM)

---

## 🛠️ Estado del Proyecto y Roadmap

Para mantener la documentación organizada y facilitar el reporte de fallos, he dividido el seguimiento técnico en secciones específicas. 

| Sección | Descripción |
| :--- | :--- | 
| [**📜 Historial de Cambios**](docs/CHANGELOG.md) | Bugs visuales, problemas de resolución y hardware específico. | 
| [**🚀 Trabajos Actuales (WIP)**](docs/ROADMAP.md) | Próximas funcionalidades, optimizaciones y tareas pendientes. | 
| [**📖 Guía de Atajos**](docs/HOTKEYS.md) | Listado completo de keybindings para bspwm y sxhkd. | 
|  [**🐛 Errores Conocidos**](docs/KNOWN_ISSUES.md) | Registro detallado de versiones y actualizaciones del script. | 

---

## 🧠 Script de Ciberseguridad

Instala las herramientas que utilizo para ciberseguridad así como también automatiza la configuracion del firewall, DNS y enjaulado de aplicaciones con firejail.

Este script fue Movido al repositorio: [neCybersecurity-Script](https://github.com/NeTenebraes/neCybersecurity-Script)

---

## 🙏 Créditos y Agradecimientos

**neBSPWM** se apoya en el excelente trabajo de la comunidad open source y artistas digitales.

| ✨ Componente | 👤 Autor | 🔗 Enlace | 📄 Licencia | 🎯 Uso |
|--------------|----------|-----------|-------------|--------|
| **SDDM Astronaut Theme** | [Keyitdev](https://github.com/Keyitdev) | [GitHub](https://github.com/Keyitdev/sddm-astronaut-theme) | **GPLv3+** | Pantalla de login |

> **Nota:** Consulta [`CREDITS.md`](CREDITS.md) para detalles completos.
