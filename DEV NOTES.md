## Problemas específicos de mi hardware

Tengo un portátil que presenta fallas con el controlador del touchpad. Estaba pensando en modificar el script para que automatice la correción del touchpad. Sin embargo, esto puede afectar el funcionamiento de los otros computadores así que por el momento lo dejo acá para tenerlo en cuenta. 

La solución es modificar una variable dentro del arranque GRUB (En caso de usar GRUB). Además, con estos valores también se solucionó el Kernel Panic a la hora de cerrar la tapa.

```bash
sudo nano /etc/default/grub                                             
```

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet i8042.nopnp=1 pci=nocsr acpi_osi=Windows\ 2015"
```

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
> El Kernel debe estar separado (No usar el KUI)

### Cambiar el Driver del mouse
Debido al problema del drive, el PC se queda con el driver generico. Nada que cambiando el driver a libinput no soluciones. De esta forma puede activar algunos gestos adicionales para el touchpad

```bash
sudo nvim /etc/X11/xorg.conf.d/30-touchpad.conf
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