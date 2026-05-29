echo_msg() { echo -e "\n\033[1;34m🛡️ $1\033[0m"; }
echo_ok()  { echo -e "\033[1;32m✅ $1\033[0m"; }
echo_skip(){ echo -e "\033[1;33m⏭️ $1\033[0m"; }
echo_err() { echo -e "\033[0;31m❌ $1\033[0m" >&2; }

# Escribe en dconf solo si el valor actual es distinto (evita reinicios innecesarios de servicios)
dconf_write_if_needed() {
    local key="$1"
    local value="$2"

    # Obtenemos el valor actual. Si falla, devolvemos un string vacío
    local current_val
    current_val=$(dconf read "$key" 2>/dev/null | sed "s/^'//;s/'$//" || echo "")

    # Limpiamos el valor de entrada para la comparativa (quitar comillas si vienen)
    local clean_value
    clean_value=$(echo "$value" | sed "s/^'//;s/'$//")

    if [[ "$current_val" != "$clean_value" ]]; then
        # Aquí dconf write sí necesita las comillas si es un string
        dconf write "$key" "$value"
        echo_ok "dconf: $key ➔ $value"
    else
        echo_skip "dconf OK: $key"
    fi
}

# Comprueba si el contenido de un archivo es EXACTAMENTE igual al string proveído
check_file_content() {
    local file="$1"
    local content="$2"
    # Si el archivo no existe, obviamente no coincide
    [[ -f "$file" ]] && cmp -s <(echo -e "$content") "$file"
}

# Escribe el contenido solo si es necesario, creando el directorio padre si falta
write_if_needed() {
    local file="$1"
    local content="$2"

    if ! check_file_content "$file" "$content"; then
        mkdir -p "$(dirname "$file")"
        echo -e "$content" > "$file"
        echo_ok "Actualizado: $file"
    else
        echo_skip "Sin cambios: $file"
    fi
}

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