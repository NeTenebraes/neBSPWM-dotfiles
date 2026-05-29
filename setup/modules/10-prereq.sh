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