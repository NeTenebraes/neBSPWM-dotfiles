check_internet() {
    echo_msg "🌐 Comprobando conexión a internet..."
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        echo_err "No hay conexión a internet. El script requiere acceso para instalar paquetes y temas."
        exit 1
    fi
    echo_ok "Conexión activa"
    echo_msg "Iniciando actualización del sistema"
    sudo pacman -Syu --noconfirm
}

select_language() {
    echo -e "\nSelecciona el idioma del sistema:"
    echo "1) Inglés | 2) Español LATAM | 3) Español España"
    read -r -p "Opción [1]: " choice
    case ${choice:-1} in
      1) export SYS_LANG="en_US.UTF-8" ;;
      2) export SYS_LANG="es_MX.UTF-8" ;;
      3) export SYS_LANG="es_ES.UTF-8" ;;
      *) export SYS_LANG="en_US.UTF-8" ;;
    esac
    echo_ok "Idioma seleccionado: $SYS_LANG"
}
