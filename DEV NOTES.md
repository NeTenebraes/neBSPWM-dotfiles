# Notas para el proyecto.

Estas notas son publicas para tener total transparencia con los avances del proyecto y las trabas del proyecto. 

---

## Problemas encontrados

### 01 Nemo no integra la terminal.

Hacer una función que esté dedicada planamente a la terminal.

Comando para establecer kitty como default dentro de nemo:
gsettings set org.cinnamon.desktop.default-applications.terminal exec 'kitty'

### 02 Problemas de rendimiendo con el script "Monitor_setup.sh" (Causas de Lag en equipos modestos)

- **Polling Agresivo de Xorg:** El uso constante de `xrandr --query` bloquea el renderizado de la GPU mientras el kernel escanea los puertos físicos.
    
- **I/O Overhead:** Escritura constante de logs y snapshots en disco (`$LOG_FILE`) cada 5 segundos.
    
- **Fork-Bombing Ligero:** El script crea decenas de sub-procesos (`$(...)`) por segundo. "Forking" es costoso

> PD: En este momento estoy buscando alternativas a usar "udev". El pulling parece no ser tanto problema en un equipo post 2020, pero para equipos más limitados pueden haber problemas de flickering a simple vista.

##### Estrategia de Optimización: Monitor Manager (Low-Res & Hardened Kernel)

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