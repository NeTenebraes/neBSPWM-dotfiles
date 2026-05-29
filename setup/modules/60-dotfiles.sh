deploy_dotfiles() {
    echo_msg "Deploy dotfiles..."
    local tmp_repo="${NE_TMP_REPO:-/tmp/neBSPWN-dotfiles}"
    local config_src="$tmp_repo/Config Files"
    local home_src="$tmp_repo/Home files"

    if [[ -d "$config_src" ]]; then
        echo_msg "Config Files → ~/.config/"
        mkdir -p "$HOME/.config"
        shopt -s dotglob nullglob
        for item in "$config_src"/*; do
            [[ ! -e "$item" ]] && continue
            local name
            name="$(basename "$item")"
            local target="$HOME/.config/$name"

            if [[ -e "$target" ]]; then
                rm -rf "$target"
                echo_msg "Borrado: $name"
            fi

            cp -rf "$item" "$target"
            echo_ok "Instalado: $name"
        done
        shopt -u dotglob nullglob
    fi

    # HOME FILES -> ~/ (BORRA Y REEMPLAZA)
    if [[ -d "$home_src" ]]; then
        echo_msg "Home Files → ~/"
        shopt -s dotglob nullglob
        for item in "$home_src"/*; do
            [[ ! -e "$item" ]] && continue
            local name
            name="$(basename "$item")"
            local target="$HOME/$name"

            if [[ -e "$target" ]]; then
                rm -rf "$target"
                echo_msg "Borrado: $name"
            fi

            cp -rf "$item" "$target"
            echo_ok "Instalado: $name"
        done
        shopt -u dotglob nullglob
    fi

    echo_ok "Dotfiles Sincronizados"
}