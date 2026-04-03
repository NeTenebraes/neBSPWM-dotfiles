#!/bin/bash

wid=$1
class=$2
instance=$3

# Si no hay ID, no hacemos nada
[ -z "$wid" ] && exit 0

# Obtenemos el título exacto
title=$(xprop -id "$wid" _NET_WM_NAME | cut -d '"' -f 2)

# Si la clase es la de Burp, aplicamos la lógica
if [ "$class" = "install4j-burp-StartBurp" ]; then
    
    # 1. Ventana de Proyecto (TILED)
    # Buscamos si el título contiene "Project"
    if [[ "$title" == *"Project"* ]]; then
        echo "state=tiled"
        
    # 2. Ventanas específicas (FLOTANTES)
    # "Settings" o el Splash screen (que no tiene "Project")
    elif [[ "$title" == "Settings" || "$title" == "Burp Suite Community Edition"* ]]; then
        echo "state=floating"
        
    # 3. Por defecto para cualquier otro popup de Burp (flotante)
    else
        echo "state=floating"
    fi
fi