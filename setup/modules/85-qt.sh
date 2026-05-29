setup_qt() {
    echo_msg "Configurando entorno Qt"

    # Configurar Kvantum
    local kvantum_config_dir="$HOME/.config/Kvantum"
    local kvantum_config_file="$kvantum_config_dir/kvantum.kvconfig"
    local kvantum_path="/usr/share/Kvantum"

    # EXTRAER nombre base: "catppuccin-mocha-mauve-standard+default" → "catppuccin-mocha-mauve"
    local kvantum_theme
    kvantum_theme=$(echo "$THEME_DEFAULT" | sed 's|-standard\+.*||' | sed 's|-hdpi||' | sed 's|-xhdpi||')
    echo_msg "GTK '$THEME_DEFAULT' → Kvantum '$kvantum_theme'"

    #TODO: Esta sección puede que esté de más, verificar en testing
    # Iniciar servicios de Portal (Run-time fix para la sesión actual)
    if ! pgrep -f "xdg-desktop-portal" >/dev/null; then
        echo_msg "🔌 Iniciando Portals (Sesión actual)..."
        /usr/lib/xdg-desktop-portal & disown
        /usr/lib/xdg-desktop-portal-gtk & disown
    fi

    echo_ok "Entorno Qt completado"
}
