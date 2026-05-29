install_pacman_packages() {
    # 2. Dependencias Esenciales Pacman
    echo_msg "📦 Instalando dependencias esenciales (Pacman)..."
    sudo pacman -S --needed --noconfirm "${PKGS_PACMAN_Essencials[@]}"

    # 3. Dependencias Opcionales Pacman
    read -r -p "¿Instalar opcionales de Pacman? (${PKGS_PACMAN_optionals[*]}) (y/N): " resp_p || true
    if [[ "$resp_p" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo pacman -S --needed --noconfirm "${PKGS_PACMAN_optionals[@]}"
    else
        echo_skip "Opcionales de Pacman omitidos."
    fi
}

install_aur_packages() {
    # 4. PAQUETES AUR ESENCIALES
    echo_msg "📦 Instalando paquetes AUR con $AUR_HELPER..."
    "$AUR_HELPER" -S --needed --noconfirm "${PKGS_AUR[@]}"

    # 5. PAQUETES AUR OPCIONALES (CORREGIDO)
    read -r -p "¿Instalar opcionales de AUR? (${PKGS_AUR_Optionals[*]}) (y/N): " resp_a || true
    if [[ "$resp_a" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        "$AUR_HELPER" -S --needed --noconfirm "${PKGS_AUR_Optionals[@]}"
    else
        echo_skip "Opcionales de AUR omitidos."
    fi
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
