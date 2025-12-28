# neBSPWM - Entorno de trabajo para Ciberseguridad

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

Mi espacio de trabajo para **ciberseguridad, hacking ético y desarrollo en Linux**.  

**Formateo mi equipo con frecuencia** y quería poder **restaurar mi entorno completo en minutos**, sin tener que volver a configurar cada detalle desde cero. Esta config esta pensada para mi trabajo en un **equipo modesto** (i3 de segunda generación y 8GB de RAM), por lo que diseñé esta configuración pensando en **rendimiento, ligereza y estabilidad**, sin sacrificar la estética ni la comodidad en largas jornadas de trabajo técnico.

El resultado es un entorno minimalista basado en **bspwm**, con **Rofi**, **Polybar**, **Conky**, **Kitty** y una paleta visual **Catppuccin Mocha**, pensado para mantenerse fluido incluso con múltiples herramientas de seguridad abiertas.

![Desktop](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Animated.webp)
> En resumen: **Una configuración que puedes reinstalar rápido, que se siente ágil en hardware antiguo, y que mantiene el mismo “flow” para programar, investigar y crear contenido.**

---

## Instalación

> **Aviso importante:**  
> Antes de ejecutar **cualquier script** en tu sistema, **siempre revisa su contenido**. Nunca ejecutes comandos remotos sin verificar su origen.  
```
git clone https://github.com/NeTenebraes/neBSPWM-dotfiles.git
cd neBSPWM-dotfiles
./setup.sh
./Cybersecurity.sh
```
**Reiniciar:** `systemctl reboot`

> Este entorno es open source: Puedes auditar y modificar los scripts en cualquier momento. 

---

### 📢 Últimas actualizaciones del proyecto
<table>
  <thead>
    <tr>
      <th>Fecha 📅</th>
      <th>Update 📰</th>
    </tr>
  </thead>
  <tbody>
    <!-- NEBSPWM:START --><tr><td>28/12/2025</td><td><a href='https://threads.net/@netenebrae/post/DSy0vdNjoMP'>Integré un pequeño módulo para el repo de neBSPWM. 

La idea sería poder mostrar los updades del proyecto directamente en el readme, todo alimentado por Thread. Veamos cómo se comporta~</a></td></tr><tr><td>28/12/2025</td><td><a href='https://threads.net/@netenebrae/post/DSyuQy3Dnm9'>Día 53 | Bugs de post-producción neBSPWM 🐛

Hoy fue día de testing intensivo. Aunque surgieron errores, lo que más valoro es cuánto estoy profundizando en la lógica de Bash y el manejo de entornos. Tuve que hacer unos cambios de último momento desde el IDE de GitHub pero todos fresco.</a></td></tr><tr><td>27/12/2025</td><td><a href='https://threads.net/@netenebrae/post/DSv1okuiePg'>💀 Día 47–52 | Proyecto NebSPWM 

Seis días de puro ricing en Arch 🐧 una guerra digna de documentar. 
 
Objetivo: dejar mi entorno BSPWM exactamente como lo imaginaba — limpio, automatizado y portable.</a></td></tr><tr><td>26/12/2025</td><td><a href='https://threads.net/@netenebrae/post/DStxbT5joSH'>&lt;div&gt;&lt;img src=&quot;https://scontent-mia3-2.cdninstagram.com/v/t51.2885-15/604674777_17920217241212873_6694358239685218171_n.jpg?stp=dst-jpg_e35_tt6&amp;efg=eyJ2ZW5jb2RlX3RhZyI6InRocmVhZHMuRkVFRC5pbWFnZV91cmxnZW4uMjE5Nng2MDIuc2RyLmY4Mjc4Ny5kZWZhdWx0X2ltYWdlLmMyIn0&amp;_nc_ht=scontent-mia3-2.cdninstagram.com&amp;_nc_cat=105&amp;_nc_oc=Q6cZ2QGyAG7RtqFShEBO48Ac6dn1i-eVjsAJu5js_w9WWADg4zs8Im-QH3r7S8JUq6ERGMs&amp;_nc_ohc=K36FBPbNxfIQ7kNvwG5SLvG&amp;_nc_gid=dTBrHadVnnexX6vdRMT0Wg&amp;edm=APs17CUBAAAA&amp;ccb=7-5&amp;ig_cache_key=Mzc5NTkwNzQ0MjAxNDg0ODEzNQ%3D%3D.3-ccb7-5&amp;oh=00_AfkbooErB1wdpWi47G67jIY_ViviftLDjFEus6eO4HYiww&amp;oe=695679A0&amp;_nc_sid=10d13b&quot; style=&quot;width: 100%;&quot; /&gt;&lt;div&gt;Felices fiestas!
Mañana traigo un update especial, han sido días de mucho formatear. Xd
Mañana update de que he estado haciendo!&lt;/div&gt;&lt;/div&gt;</a></td></tr><tr><td>20/12/2025</td><td><a href='https://threads.net/@netenebrae/post/DSePbdSjhj_'>&lt;div&gt;&lt;img src=&quot;https://scontent-mia3-2.cdninstagram.com/v/t51.2885-15/601324882_17919510960212873_4219472261852078694_n.webp?efg=eyJ2ZW5jb2RlX3RhZyI6InRocmVhZHMuQ0FST1VTRUxfSVRFTS5pbWFnZV91cmxnZW4uMTA4MHgxMDAxLnNkci5mODI3ODcuZGVmYXVsdF9pbWFnZS5jMiJ9&amp;_nc_ht=scontent-mia3-2.cdninstagram.com&amp;_nc_cat=105&amp;_nc_oc=Q6cZ2QH1S-uui2uJ3h9Fen6ZHt3cfGV91vEhcDrZcJ9C7P-KGYLc4hSPji6rw5GGejJiAAs&amp;_nc_ohc=tiib_4PrSgEQ7kNvwErBAJN&amp;_nc_gid=v4ZlL6ha4F9r4a4qDtq3vw&amp;edm=APs17CUBAAAA&amp;ccb=7-5&amp;ig_cache_key=Mzc5MTUzNTc4ODI3MDY5MzE2Mw%3D%3D.3-ccb7-5&amp;oh=00_Afm5xeIou_IOVa5zuxt-BycqTeD8EePjb3KrhH9fOEwTzQ&amp;oe=69566E14&amp;_nc_sid=10d13b&quot; style=&quot;width: 100%;&quot; /&gt;&lt;div&gt;Día 46 | Ricing en Arch 💀 

Aunque no lo crean, customizable Arch puede ser 10% estética y 90% pelear con archivos de configuración. Hoy la victoria fue contra LightDM y los permisos rotos 🐧⚔️

✅ Catppuccin Mocha aplicado.
✅ Automatización del entorno lista.

Mañana: Polybar, módulos custom y el toque final.&lt;/div&gt;&lt;/div&gt;</a></td></tr><!-- NEBSPWM:END -->
  </tbody>
</table>

---

## ✨ Características

- **Window Manager:** bspwm + sxhkd
- **Display Manager:** SDDM.
- **Launcher:** Rofi (drun mode).
- **Status Bar:** Polybar con módulos de:
  - Administración de sistema (Power menu, workspaces, volumen, batería, System Tray).
  - **Detección de Tarjetas de red y su IP local**
- **System Widget:** Conky personalizado:
  - muestra info de sistema, red, almacenamiento y procesos activos
  - incluye panel de **Network & Security** con IP local, DNS, ping y estado de firewall/VPN, como en el dashboard del escritorio.
- **Terminal:** Kitty + ZSH + Starship  
- **Lock Screen:** betterlockscreen  
- **Themes:** Catppuccin Mocha + Papirus Dark + Nerd Fonts  
- **Screenshots:** maim + xclip + notificaciones  
- **Guía Atajos:** [![HOTKEYS](https://img.shields.io/badge/HOTKEYS-Guide-4F46E5?style=flat&logo=keyboard&logoColor=white)](docs/HOTKEYS.md)

## 📦 Requisitos

- Equipo basado en **Arch Linux** (también funciona en derivados como *EndeavourOS* o *Manjaro*).  
- `paru` (se instala automáticamente).  
- ~2 GB de espacio para dependencias.  

**El script instala y configura automáticamente:**
- bspwm, sxhkd, polybar, picom, rofi, dunst, kitty, conky  
- sddm, zsh, starship, neovim, maim, betterlockscreen  
- Temas GTK/Qt **Catppuccin Mocha**, íconos **Papirus Dark**, y **Nerd Fonts**

---

## 🖼️ Screenshots

| Componente | Vista |
|------------|-------|
| Escritorio | ![Main1](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Main1.png) |
| Escritorio | ![Main2](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Main2.png) |
| Rofi | ![Rofi](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/Rofi.png) |
| Login Screen | ![SDDM](https://github.com/NeTenebraes/neBSPWM-dotfiles/blob/main/screeshots/SDDM.png) |

---

## 🧠 Script de Ciberseguridad

El archivo **`Cybersecurity.sh`** complementa este entorno, preparando Arch Linux para un flujo de trabajo orientado a **ciberseguridad, bug bounty y análisis de vulnerabilidades**. Su enfoque no es estético, sino funcional: **automatiza tareas técnicas que normalmente requerirían decenas de pasos manuales**.

### 🔍 ¿Qué diablos hace?

- **Integra herramientas de seguridad** dentro del entorno gráfico, respetando la estética del sistema *(íconos, menús en Rofi y accesos integrados en `~/.local/share/applications`)*.  
- **Instala y configura herramientas esenciales de hacking y análisis:**
  - **Burp Suite Community** → Proxy y escáner HTTP/S, con wrapper optimizado para Wayland/X11.
  - **Caido** → Proxy moderno y liviano, descargado dinámicamente desde GitHub e integrado directamente al menú de aplicaciones.
  - **Firejail** → Crea **navegadores aislados** con perfiles diferenciados:
    - *Navegador Personal*: aislamiento estándar, pensada para uso diario.  
    - *Navegador Bug Bounty*: entorno sandbox con red privada, DNS dedicados y caché independiente, ideal para investigación y pruebas sin contaminar tus perfiles personales.
- **Virtualización configurada automáticamente:**
  - Detecta el kernel actual *(Hardened, LTS o Zen)* e instala sus *headers* correspondientes.
  - Configura **VirtualBox** y **VMware Workstation** con módulos, red *Host-Only* funcional y soporte para entornos de laboratorio listos para pentesting.
- **Red y protección general automatizada:**
  - Activa **UFW** con reglas predefinidas *(Deny IN / Allow OUT)*.
  - Ofrece habilitar **SSH** de forma opcional.
  - Aplica resolutores **DNS seguros** (Cloudflare, Quad9 o Google) para toda la red del sistema.
- **Flujo de pentesting completamente automatizado:**  
  Al finalizar, todas las herramientas quedan:
  - Integradas visualmente en **Rofi**.  
  - Añadidas al **PATH del usuario**.  
  - Ejecutables sin `sudo` ni elevación de privilegios innecesaria.  

En resumen: Un script que convierte tu instalación limpia de Arch en un **laboratorio de ciberseguridad funcional, seguro y visualmente coherente** en menos de 2min 💀

> Ejecuta este script **después** de `setup.sh` para convertir tu entorno en un laboratorio de ciberseguridad completo, coherente en diseño, rendimiento y funcionalidad.

---

## 🙏 Créditos y Agradecimientos

**neBSPWM** se apoya en el excelente trabajo de la comunidad open source y artistas digitales.

| ✨ Componente | 👤 Autor | 🔗 Enlace | 📄 Licencia | 🎯 Uso |
|--------------|----------|-----------|-------------|--------|
| **SDDM Astronaut Theme** (modificado) | [Keyitdev](https://github.com/Keyitdev) | [GitHub](https://github.com/Keyitdev/sddm-astronaut-theme) ⭐2k+ | **GPLv3+** | Pantalla de login |
| **Fondos de pantalla** | [Timeless](https://x.com/Timeless_aiart) | [X/Twitter](https://x.com/Timeless_aiart) | Uso personal | Wallpapers cyberpunk/anime |

> **Nota:** Consulta [`CREDITS.md`](CREDITS.md) para detalles completos.
---
> ⚠️ **Aviso / Disclaimer**  
> Este entorno fue probado únicamente en **dos equipos** con la **misma resolución** *(1920x1080)* y hardware similar *(Intel i3 2da + 8 GB RAM)*.  
> Es totalmente funcional en esas condiciones, pero en otros entornos pueden aparecer **errores visuales o pequeños bugs**.  
>
> 💡 **Recomendación:** Antes de ejecutar cualquier script, **haz una copia de seguridad de tu carpeta `~/.config/`**.  
> Durante la instalación, varios directorios se reemplazan por completo para aplicar la configuración.  
> 
> 🔧 **Compatibilidad:** Este script está diseñado para una **instalación limpia de Arch Linux** o derivados como **Manjaro** y **EndeavourOS**.  
> 
> Si algo se rompe: Saca un pantallazo y **abre un issue en GitHub**. Cada bug ayuda a mejorar este proyecto, versión tras versión.
