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
