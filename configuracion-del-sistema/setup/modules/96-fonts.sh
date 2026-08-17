detect_system_lang() {
    local system_lang=""
    if [[ -f /etc/locale.conf ]]; then
        system_lang=$(sed -n 's/^LANG=//p' /etc/locale.conf | tr -d '"')
    fi
    system_lang=${system_lang:-${LANG:-}}
    echo "$system_lang"
}

configure_fontconfig_preference() {
    echo_msg "Configurando preferencia de fuentes"
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

refresh_font_cache() {
    sudo fc-cache -fv > /dev/null
    fc-cache -fv > /dev/null
}

setup_fonts_locale() {
    echo_msg "🅰️  Configurando FUENTES + LOCALE..."

    local system_lang
    system_lang=$(detect_system_lang)
    if [[ -n "$system_lang" ]]; then
        echo_ok "Idioma del sistema: $system_lang"
    else
        echo_skip "No se detectó LANG del sistema; se omite configuración de locale"
    fi
    configure_fontconfig_preference
    refresh_font_cache

    echo_ok "🅰️  Fuentes + Locale COMPLETO (Global Mode)"
}
