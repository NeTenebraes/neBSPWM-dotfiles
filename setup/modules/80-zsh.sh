#TODO: Separar normal user y root en dos funciones

setup_zsh() {
    echo_msg "Configurando ZSH + Starship para $USER y Root..."

    # Instalar Starship si no existe
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo_ok "Starship instalado globalmente"
    else
        echo_skip "Starship ya está instalado"
    fi

    # Cambiar shell a ZSH para el usuario actual
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        chsh -s /usr/bin/zsh
        echo_ok "ZSH configurado para $USER"
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

    echo_ok "ZSH y Starship listos en ambos usuarios"
}