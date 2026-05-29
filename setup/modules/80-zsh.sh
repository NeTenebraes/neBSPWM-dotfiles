#TODO: Separar normal user y root en dos funciones

setup_zsh() {
    echo_msg "Configurando ZSH + Starship para $USER y Root..."
    local zsh_path="/usr/bin/zsh"

    # Instalar Starship si no existe
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo_ok "Starship instalado globalmente"
    else
        echo_skip "Starship ya está instalado"
    fi

    # Cambiar shell a ZSH para el usuario actual
    if [[ "$SHELL" != "$zsh_path" ]]; then
        chsh -s "$zsh_path"
        echo_ok "ZSH configurado para $USER"
    fi

    # --- INTEGRACIÓN PARA ROOT ---
    echo_msg "Sincronizando configuración con Root..."

    # Cambiar shell de root a ZSH si hace falta
    local root_shell
    root_shell=$(getent passwd root | cut -d: -f7)
    if [[ "$root_shell" != "$zsh_path" ]]; then
        if grep -qx "$zsh_path" /etc/shells; then
            sudo chsh -s "$zsh_path" root || sudo usermod -s "$zsh_path" root
            echo_ok "ZSH configurado para root"
        else
            echo_err "ZSH no está en /etc/shells: $zsh_path"
        fi
    else
        echo_skip "ZSH ya está configurado para root"
    fi

    # Crear directorio de config para root si no existe
    sudo mkdir -p /root/.config

    # Enlazar simbólicamente tu config actual a la de root
    # Así, si editas tu config, la de root se actualiza sola.
    if [[ -f "$HOME/.config/starship.toml" ]]; then
        sudo ln -sf "$HOME/.config/starship.toml" /root/.config/starship.toml
    else
        echo_err "No existe: $HOME/.config/starship.toml"
    fi

    # Enlazar la config de ZSH para root
    if [[ -f "$HOME/.zshrc" ]]; then
        sudo ln -sf "$HOME/.zshrc" /root/.zshrc
        echo_ok "ZSH sincronizado: /root/.zshrc → $HOME/.zshrc"
    else
        echo_err "No existe: $HOME/.zshrc"
    fi

    echo_ok "ZSH y Starship listos en ambos usuarios"
}
