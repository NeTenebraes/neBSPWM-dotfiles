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
