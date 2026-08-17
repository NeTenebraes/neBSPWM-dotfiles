setup_zsh() {
    echo_msg "Configurando ZSH + Starship..."
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

    echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zsh/zshenv

    echo_ok "ZSH y Starship listos"
}
