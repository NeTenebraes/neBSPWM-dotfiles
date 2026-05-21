# 📜 Historial de Cambios

Todos los cambios notables en este proyecto serán documentados en este archivo.

> Este documento lo realicé mucho despues de crear el proyecto, empezaré a actualizar el mismo en futuros cambios.

---
## [1.2.0] - 2026-05-20

### nvim (EXPERIMENTAL)
- Se ha hecho una limpieza general a los plugins de `nvim`. La idea es poder contar con un entorno visualmente coherente sin depender de tantos plugins externos. Esto con el fin de mantener una mayor seguridad en el SO.

### Modulo nuevo de Polybar.
- Colorpicker: Se ha añadido un modulo a `polybar` para facilitar el desarrollo web. Ahora tiene la opcion se poder elegir cualquier color directamente desde la polybar.

### Modificaciones a Fix_Windows.
- He estado jugando osrs, por lo que he modificado/agregado un par de funciones al script de bspwm `fix_windows.sh` para lograr una coherencia con el entorno.

### Setup.sh (BUGFIX)
- He agregado las dependecias necesarias para que lo anterior funcione sin problemas. También he corregido un pequeño bug que no incorporaba de forma correcta VSCodium al entorno.
- Se ha eliminado completamen la dependencia "`npm`" y se ha sibstituido por "`pnpm`". También se ha agregado un enlace símbolico para que todo lo relacionado a `npm` funcione directame con `pnpm`.

### 🚀 Estado del Proyecto

> El entorno ha estado agarrando mucha forma en comparación con la primera versión. Lo siguiente que veo coherente es empezar a mejorar la arquitectura del instalador. He pensado en migrar a otro lenguaje, pero honestamente me gusta mucho BASH.

---


## [1.1.0] - 2026-04-08

### SCRIPTS - MONITOR_Manager (BUGFIX)

#### Monitor_Manager.sh, UI_Refresh.sh & Layout_Engine.sh 

- **Estabilidad:** Se declara el script del monitor como estable tras corregir bugs críticos de detección de hardware.
- **Persistencia de Estados:** Optimización de `layout_engine.sh` y la función `fix_floating_nodes` para que las ventanas mantengan su estado (flotante/tile) al cambiar de monitor, solucionando el problema de ventanas "perdidas" en aplicaciones como GIMP.
- **Detección Nativa:** Sustitución de `xtitle` por llamadas nativas a `xprop` (WM_CLASS) para mejorar la compatibilidad sin dependencias externas innecesarias.
- **Refresco de Interfaz:** Optimización del ciclo de reinicio de Polybar, feh (wallpaper) y Conky para asegurar que la UI se adapte instantáneamente a los cambios de resolución o disposición de monitores.
- **Limpieza de Procesos:** Mejora en el manejo de señales para evitar procesos huérfanos de la barra de estado al desconectar pantallas.

### Setup.sh

- **Gestión de Dependencias:** Se añadió `xdotool` a la lista de dependencias críticas del sistema para permitir la manipulación de geometría de ventanas y el correcto funcionamiento de los scripts de "fix".
- **Nueva Terminal:** Se ha configurado **Kitty** como la terminal por defecto en `setup.sh`, reemplazando la anterior para aprovechar su rendimiento y soporte de protocolos.

### Documentación y Notas de Desarrollo

- **Dev Notes:** Creación de la nota técnica "Dev Notes", diseñada para centralizar conocimientos sobre la configuración de equipos y flujos de trabajo personales.
- **Actualización de Proyectos:** Editadas las secciones de _"Working on"_ y _"Dev Notes"_ para reflejar el estado actual del desarrollo.

---
### 🚀 Estado del Proyecto

> "Por el momento no veo que haga falta nada critico, si de pronto encuentro algo lo estaré avisando por threads"
---
[⬅️ Volver al README](../README.md)
