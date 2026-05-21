ensure_aur_helper() {
    # --- LÓGICA AUR HELPER: DETECTAR O INSTALAR ---
    local helpers=("yay-bin" "paru" "yay")
    AUR_HELPER=""

    # 1. Intentar detectar un helper ya instalado
    for h in "paru" "yay"; do
        if command -v "$h" >/dev/null; then
            AUR_HELPER="$h"
            break
        fi
    done

    if [[ -n "$AUR_HELPER" ]]; then
        echo_ok "Se detectó '$AUR_HELPER' instalado."
        read -r -p "¿Deseas seguir usando $AUR_HELPER? [S/n]: " keep_existing
        [[ "$keep_existing" =~ ^([nN][oO]|[nN])$ ]] && AUR_HELPER=""
    fi

    # 2. Si no hay ninguno o el usuario decidió cambiarlo
    if [[ -z "$AUR_HELPER" ]]; then
        echo -e "\n--- Instalación de AUR Helper ---"
        PS3="Selecciona cuál deseas instalar: "
        select opt in "${helpers[@]}" "Cancelar"; do
            case $opt in
                "yay-bin"|"paru"|"yay")
                    # Si había uno anterior, lo quitamos para no tener conflictos
                    # Buscamos si existe algun binario para borrarlo antes
                    for old in "paru" "yay"; do
                        if command -v "$old" >/dev/null; then
                            echo_msg "Eliminando $old antiguo..."
                            sudo pacman -Rs --noconfirm "$old"
                        fi
                    done

                    echo_msg "Instalando $opt..."
                    sudo pacman -S --needed --noconfirm base-devel git

                    build_dir=$(mktemp -d)
                    git clone "https://aur.archlinux.org/$opt.git" "$build_dir"
                    (cd "$build_dir" && makepkg -si --noconfirm)
                    rm -rf "$build_dir"

                    AUR_HELPER="${opt%-bin}"
                    break
                    ;;
                "Cancelar")
                    echo_err "No se seleccionó ningún AUR Helper. Saliendo..."
                    exit 1
                    ;;
                *) echo "Opción no válida";;
            esac
        done
    fi

    export AUR_HELPER
    echo_ok "Usando $AUR_HELPER para el resto de la instalación."
}
