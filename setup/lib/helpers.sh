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