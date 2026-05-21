setup_zsh() {
    echo_msg "Configurando ZSH + Starship para $USER y Root..."

    # 1. Cambiar shell a ZSH para el usuario actual
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        chsh -s /usr/bin/zsh
        echo_ok "ZSH configurado para $USER"
    fi

    # 2. Instalar Starship si no existe
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo_ok "Starship instalado globalmente"
    else
        echo_skip "Starship ya está instalado"
    fi

    # 3. Configurar el archivo .zshrc para el usuario actual
    if ! grep -q 'starship init zsh' ~/.zshrc; then
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        echo_ok "Starship añadido al .zshrc de $USER"
    fi

    # --- INTEGRACIÓN PARA ROOT ---
    echo_msg "Sincronizando configuración con Root..."

    # Cambiar shell de root a ZSH
    sudo chsh -s /usr/bin/zsh root

    # Crear directorio de config para root si no existe
    sudo mkdir -p /root/.config

    # Enlazar simbólicamente tu config actual a la de root
    # Así, si editas tu config, la de root se actualiza sola.
    sudo ln -sf "$HOME/.config/starship.toml" /root/.config/starship.toml

    # Añadir inicialización al .zshrc de root
    if ! sudo grep -q 'starship init zsh' /root/.zshrc 2>/dev/null; then
        echo 'eval "$(starship init zsh)"' | sudo tee -a /root/.zshrc > /dev/null
        echo_ok "Starship añadido al .zshrc de Root"
    fi

    echo_ok "ZSH y Starship listos en ambos usuarios"
}
