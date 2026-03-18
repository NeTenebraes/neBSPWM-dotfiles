## 01. Problemas de rendimiento con el script "Monitor_setup.sh".

- **Polling Agresivo de Xorg:** El uso constante de `xrandr --query` bloquea el renderizado de la GPU mientras el kernel escanea los puertos físicos.
- **I/O Overhead:** Escritura constante de logs y snapshots en disco (`$LOG_FILE`) cada 5 segundos.
- **Fork-Bombing Ligero:** El script crea decenas de sub-procesos (`$(...)`) por segundo. "Forking" es costoso

> PD: En este momento estoy buscando alternativas a "udev". El pulling parece no ser tanto problema en un equipo post 2020, pero para equipos más limitados pueden haber problemas de flickering a simple vista.

#### Estrategia de Optimización: Monitor Manager

1. Cambio de Paradigma: Detección Pasiva
El error principal es usar `xrandr` como sensor.
- **Acción:** Sustituir consultas de `xrandr` por lectura de archivos en `/sys/class/drm/`.
- **Por qué:** Leer un archivo de `/sys` es una operación sencilla a nivel de Kernel. No genera (forks), no requiere conexión al servidor X y es instantáneo incluso en CPUs antiguas.
- **Nota Hardened:** El kernel suele permitir lectura de `/sys` a nivel de usuario (grupo video), mientras que `udev` puede estar restringido.

2. Implementación de "Fingerprinting" (Huella de Hardware)
No procesar lógica si nada ha cambiado físicamente.
- **Acción:** Crear una variable `HW_ID` que concatene el contenido de `/sys/class/drm/*/status` y el estado del LID.
- **Lógica:** `NUEVA_HUELLA=$(cat /sys/class/drm/card*-*/status)`
  Si `HUELLA_ACTUAL == NUEVA_HUELLA`, ejecutar `continue` y dormir.
- **Impacto:** Reduces el uso de CPU de "picos constantes" a "reposo absoluto".
> PD: Esto es solo teoría, tengo que verificar que no interfiera con otros procesos relacionados al LID.

3. Caché de Información en Memoria RAM (`/dev/shm`)
Mover la logica de lock a RAM, esto evitaria usar el disco para la creacion de archivos temporales o de estado.
- **Acción:** Mover `STATE_FILE` y `LOCK_FILE` a `/dev/shm/`.
- **Por qué:** `/dev/shm` es una partición en RAM (tmpfs). La latencia de lectura/escritura es órdenes de magnitud menor que en `/tmp` o `$HOME`.

4. Reducción de "Forks" de Shell (Bash Builtins)
Me recomendaron no usar `$(command | grep | awk)` ya que el i3 tiene que crear 3 procesos nuevos.
- **Acción:** Usar manipulación de strings nativa de Bash.
- **Ejemplos:**
    - Mal: `echo $GEOM | cut -d+ -f2`
    - Bien: `${GEOM#*+}` (Bash nativo)
    - Mal: `cat file | grep "string"`
    - Bien: `[[ $( < file) == *"string"* ]]`
> PD: Aún soy muy novato en bash entonces no sé como diablos implementar esto bien, ya lo averiguaremos. 

5. Batching de Comandos `bspc`
Llamar a `bspc` 20 veces para mover 10 desktops es ineficiente.
- **Acción:** Agrupar acciones. `bspc` permite realizar ciertas operaciones en bloque o reordenar monitores de un solo golpe con `bspc monitor -o ...`.
- **Idea:** Si necesitas mover muchas ventanas, es más barato usar `bspc wm -r` (reiniciar el gestor) con una configuración nueva que mover nodos uno a uno en un bucle lento.
> PD: Tengo que verificar puesto que, de la forma que lo estaba intentando, bspc no estaba reorganizando los workspaces de la forma esperada.

6. Workflow pensado:
1. **Loop (Sleep 5-10s)**
2. **Sniffing:** ¿Ha cambiado `/sys/class/drm/*/status`?
3. **Exit rápido:** Si NO, volver al punto 1.
4. **Heavy Lift:** Si SÍ, hacer UNA sola llamada a `xrandr --query` y guardarla en una variable.
5. **Logic:** Procesar esa variable en memoria para decidir el modo (Dual/Single).
6. **Apply:** Ejecutar cambios y actualizar el hash en `/dev/shm`.

---
## 02. Nemo no integra la terminal.

Hacer una función que esté dedicada plenamente a la terminal.

Comando para establecer kitty como default dentro de nemo:
```bash
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'kitty'
```

---
## 03. Problemas especificos de mi hardware

Tengo un portátil que presenta fallas con el controlador del touchpad. Estaba pensando en modificar el script para que automatice la correción del touchpad. Sin embargo, esto puede afectar el funcionamiento de los otros computadores así que por el momento lo dejo acá para tenerlo en cuenta. La solución es modificar una variable dentro del arranque GRUB (En caso de usar GRUB). Además, con estos valores también se solucionó el Kernel Panic a la hora de cerrar la tapa.

```
sudo nano /etc/default/grub                                             
```

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet i8042.nopnp=1 pci=nocsr acpi_osi=Windows\ 2015"
```

### Cambiar el Driver del mouse
Debido al problema del drive, el PC se queda con el driver generico. Nada que cambiando el driver a libinput no soluciones. De esta forma puede activar algunos gestos adicionales para el touchpad

```bash
cat /etc/X11/xorg.conf.d/30-touchpad.conf
```

```
Section "InputClass"
    Identifier "ETPS/2 Elantech Touchpad"
    MatchIsTouchpad "on"
    Driver "libinput"
    Option "Tapping" "on"
    Option "NaturalScrolling" "false"
    Option "AccelProfile" "adaptive"
    Option "AccelSpeed" "0.1"
    Option "DisableWhileTyping" "true"
    Option "ClickMethod" "clickfinger"
    
    # --- PARÁMETROS PARA RUIDO ELÉCTRICO ---
    # Aumenta el umbral de presión para reconocer un toque.
    # Nota: Libinput no siempre expone FingerLow/High directamente, 
    # pero estas opciones ayudan a la estabilidad:
    Option "HorizontalScrolling" "on"
    Option "ScrollMethod" "twofinger"
    
    # Si el cursor salta mucho, bajar la aceleración aun más puede ayudar 
    # a que el "ruido" no mueva el puntero media pantalla.
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1.2"
EndSection
```