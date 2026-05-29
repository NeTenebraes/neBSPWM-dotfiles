detect_system_lang() {
    local system_lang=""
    if [[ -f /etc/locale.conf ]]; then
        system_lang=$(sed -n 's/^LANG=//p' /etc/locale.conf | tr -d '"')
    fi
    system_lang=${system_lang:-${LANG:-}}

    if [[ -n "$system_lang" ]]; then
        echo_ok "Idioma del sistema: $system_lang"
    else
        echo_skip "No se detectó LANG del sistema; se omite configuración de locale"
    fi

    echo "$system_lang"
}

configure_fontconfig_preference() {
    echo_msg "🌐 Configurando preferencia de fuentes (Fontconfig)..."
    sudo mkdir -p /etc/fonts/conf.d
    sudo tee /etc/fonts/conf.d/50-nebspwm-fonts.conf >/dev/null << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono Nerd Font</family>
      <family>JetBrains Mono</family>
      <family>Noto Sans Mono</family>
    </prefer>
  </alias>

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
}

configure_xresources_rendering() {
    echo_msg "🖥️  Configurando X11 rendering (.Xresources)..."
    cat > "$HOME/.Xresources" << 'EOF'
Xft.dpi: 96
Xft.autohint: 0
Xft.lcdfilter: lcddefault
Xft.hintstyle: hintslight
Xft.antialias: 1
Xft.rgba: rgb
EOF
}

inject_bspwm_locale() {
    local system_lang="$1"
    local bspwm_config="$HOME/.config/bspwm/bspwmrc"
    if [[ -f "$bspwm_config" ]]; then
        sed -i '/xrdb -merge.*Xresources/d; /export LANG=/d; /export LC_ALL=/d' "$bspwm_config"

        if [[ -n "$system_lang" ]]; then
            sed -i "2i xrdb -merge ~/.Xresources\nexport LANG=${system_lang}\nexport LC_ALL=${system_lang}" "$bspwm_config"
        else
            sed -i "2i xrdb -merge ~/.Xresources" "$bspwm_config"
        fi
        echo_ok "Persistencia añadida a bspwmrc"
    fi
}

refresh_font_cache() {
    xrdb -merge "$HOME/.Xresources" 2>/dev/null
    sudo fc-cache -fv > /dev/null
    fc-cache -fv > /dev/null
}

setup_fonts_locale() {
    echo_msg "🅰️  Configurando FUENTES + LOCALE (JetBrains + Unicode Global)..."

    local system_lang
    system_lang=$(detect_system_lang)
    configure_fontconfig_preference
    configure_xresources_rendering
    inject_bspwm_locale "$system_lang"
    refresh_font_cache

    echo_ok "🅰️  Fuentes + Locale COMPLETO (Global Mode)"
}
