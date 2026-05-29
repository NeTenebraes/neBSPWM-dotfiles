configure_desktop_basics() {
    # 5.5 VSCodium y 6. Nemo/Fonts
    if command -v codium >/dev/null 2>&1; then
        mkdir -p ~/.config/VSCodium/User
        write_if_needed ~/.config/VSCodium/User/settings.json '{"terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono"}'
    fi
    gsettings set org.nemo.preferences show-image-thumbnails 'always'
    gsettings set org.nemo.preferences thumbnail-limit "18446744073709551615"
    gsettings set org.nemo.preferences inherit-show-thumbnails true
    rm -rf ~/.cache/thumbnails/*
    fc-cache -fv
    echo_ok "Nemo thumbnails ✅"

    #5.6 Añadir engrampa al menú contextual de Nemo

    # Crear el directorio si no existe (SOLO INGLES)
    mkdir -p ~/.local/share/nemo/actions

    # 1. Extract Here
    cat <<EOF > ~/.local/share/nemo/actions/engrampa-extract.nemo_action
[Nemo Action]
Active=true
Name=Extract with Engrampa
Comment=Extract the contents here using Engrampa
Exec=engrampa --extract-here %F
Icon-Name=archiver
Selection=s
Extensions=zip;7z;tar;tar.gz;tar.bz2;rar;gz;bz2;
Quote=double
EOF

    # 2. Compress
    cat <<EOF > ~/.local/share/nemo/actions/engrampa-compress.nemo_action
[Nemo Action]
Active=true
Name=Compress with Engrampa...
Comment=Create a compressed archive with Engrampa
Exec=engrampa --default-dir=%P --add %F
Icon-Name=archiver
Selection=any
Extensions=any
Quote=double
EOF

    # 6. Configuración de Renderizado y Fontconfig (Inyectado aquí)
    echo_msg "🌐 Configurando Fontconfig y X11 rendering..."
    # Aplicar el XML de Fontconfig
    sudo mkdir -p /etc/fonts/conf.d
    sudo tee /etc/fonts/conf.d/99-nebspwn.conf >/dev/null << 'EOF'
<?xml version='1.0'?><!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <alias><family>monospace</family><prefer><family>JetBrains Mono</family></prefer></alias>
  <alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Color Emoji</family></prefer></alias>
</fontconfig>
EOF

    # Aplicar Xresources inmediatamente
    write_if_needed "$HOME/.Xresources" "Xft.dpi: 96\nXft.autohint: 1\nXft.lcdfilter: lcddefault\nXft.hintstyle: hintfull\nXft.antialias: 1\nXft.rgba: rgb"
    xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
}
