setup_fonts_locale() {
    echo_msg "🅰️  Configurando FUENTES + LOCALE (JetBrains + Unicode Global)..."

    # 1. Selección de Idioma (Locale)
    echo "Selecciona el idioma del sistema:"
    echo "1) Inglés (en_US.UTF-8)"
    echo "2) Español LATAM (es_MX.UTF-8)"
    echo "3) Español España (es_ES.UTF-8)"
    read -r -p "Opción (1, 2 o 3) [1]: " choice
    choice=${choice:-1}

    case $choice in
      1) LANG="en_US.UTF-8"; echo_ok "Idioma: INGLÉS" ;;
      2) LANG="es_MX.UTF-8"; echo_ok "Idioma: ESPAÑOL LATAM" ;;
      3) LANG="es_ES.UTF-8"; echo_ok "Idioma: ESPAÑOL ESPAÑA" ;;
      *) LANG="en_US.UTF-8"; echo_ok "Idioma: INGLÉS" ;;
    esac

    # 2. Configuración GLOBAL de Fontconfig (/etc/fonts/local.conf)
    # Proporciona soporte de iconos a todos los usuarios, incluido Root.
    echo_msg "🌐 Configurando Fontconfig Global (/etc/fonts/local.conf)..."
    sudo tee /etc/fonts/local.conf >/dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font</family>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>

  <match target="pattern">
    <test qual="any" name="family"><string>JetBrains Mono</string></test>
    <edit name="family" mode="assign" binding="same"><string>JetBrainsMono Nerd Font</string></edit>
  </match>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans</family>
      <family>JetBrainsMono Nerd Font</family>
      <family>Noto Color Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOF

    # 3. Xresources para renderizado (User Level)
    echo_msg "🖥️  Configurando X11 rendering (.Xresources)..."
    cat > "$HOME/.Xresources" << 'EOF'
Xft.dpi: 96
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintslight
Xft.antialias: 1
Xft.rgba: rgb
EOF

    # 4. Inyección de variables en bspwmrc
    local bspwm_config="$HOME/.config/bspwm/bspwmrc"
    if [[ -f "$bspwm_config" ]]; then
        # Limpiar inyecciones previas (evita redundancia)
        sed -i '/xrdb -merge.*Xresources/d; /export LANG=/d; /export LC_ALL=/d' "$bspwm_config"

        # Inyectar tras el shebang (línea 2) para asegurar carga temprana
        sed -i "2i xrdb -merge ~/.Xresources\nexport LANG=${LANG}\nexport LC_ALL=${LANG}" "$bspwm_config"
        echo_ok "Persistencia añadida a bspwmrc"
    fi

    # 5. Aplicar Locale al sistema (Root)
    echo_msg "🌍 Aplicando cambios de Locale en /etc/locale.gen..."
    sudo sed -i "s/^#${LANG} UTF-8/${LANG} UTF-8/" /etc/locale.gen
    sudo locale-gen > /dev/null
    echo "LANG=${LANG}" | sudo tee /etc/locale.conf >/dev/null

    # 6. Limpieza de basura y Refresco de caché
    # Borramos config local de usuario para que mande la global de /etc/
    [[ -f "$HOME/.config/fontconfig/fonts.conf" ]] && rm "$HOME/.config/fontconfig/fonts.conf"

    xrdb -merge "$HOME/.Xresources" 2>/dev/null
    sudo fc-cache -fv > /dev/null
    fc-cache -fv > /dev/null

    echo_ok "🅰️  Fuentes + Locale COMPLETO (Global Mode)"
}
