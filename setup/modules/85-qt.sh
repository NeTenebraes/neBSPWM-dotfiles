setup_qt() {
    echo_msg "🎨 Configurando entorno Qt (BSPWM + Wayland/X11 Hybrid)..."

    # 2. Configurar Variables de Entorno en BSPWM
    # Inyectamos configuración robusta al inicio de bspwmrc para asegurar que carguen antes que las apps
    local bspwm_config="$HOME/.config/bspwm/bspwmrc"

    # Creamos el archivo si no existe (raro si ya corriste deploy_dotfiles, pero preventivo)
    if [[ ! -f "$bspwm_config" ]]; then
        mkdir -p "$(dirname "$bspwm_config")"
        touch "$bspwm_config"
        echo "#!/bin/sh" > "$bspwm_config"
        chmod +x "$bspwm_config"
    fi

    # 3. Configurar Kvantum (Extrae nombre base de THEMEDEFAULT)
    local kvantum_config_dir="$HOME/.config/Kvantum"
    local kvantum_config_file="$kvantum_config_dir/kvantum.kvconfig"
    local kvantum_path="/usr/share/Kvantum"

    # 🔧 EXTRAER nombre base: "catppuccin-mocha-mauve-standard+default" → "catppuccin-mocha-mauve"
    local kvantum_theme
    kvantum_theme=$(echo "$THEME_DEFAULT" | sed 's|-standard\+.*||' | sed 's|-hdpi||' | sed 's|-xhdpi||')
    echo_msg "🌑 GTK '$THEMEDEFAULT' → Kvantum '$kvantum_theme'"


    # 4. Iniciar servicios de Portal (Run-time fix para la sesión actual)
    if ! pgrep -f "xdg-desktop-portal" >/dev/null; then
        echo_msg "🔌 Iniciando Portals (Sesión actual)..."
        /usr/lib/xdg-desktop-portal & disown
        /usr/lib/xdg-desktop-portal-gtk & disown
    fi

    echo_ok "✅ Entorno Qt completado"
}
