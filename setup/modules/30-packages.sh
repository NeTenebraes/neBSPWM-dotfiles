configure_vscodium() {
    if command -v codium >/dev/null 2>&1; then
        mkdir -p ~/.config/VSCodium/User
        write_if_needed ~/.config/VSCodium/User/settings.json '{"terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono"}'
    fi
}

configure_nemo_thumbnails() {
    gsettings set org.nemo.preferences show-image-thumbnails 'always'
    gsettings set org.nemo.preferences thumbnail-limit "18446744073709551615"
    gsettings set org.nemo.preferences inherit-show-thumbnails true
    rm -rf ~/.cache/thumbnails/*

    echo_ok "Nemo thumbnails"
}

configure_nemo_engrampa_actions() {
    mkdir -p ~/.local/share/nemo/actions

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
}

##TODO: Separar esto en dos funciones
configure_fontconfig_xresources() {
    echo_msg "Configurando Fontconfig y X11 rendering..."
    sudo mkdir -p /etc/fonts/conf.d
    sudo tee /etc/fonts/conf.d/99-nebspwn.conf >/dev/null << 'EOF'
<?xml version='1.0'?><!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
  <alias><family>monospace</family><prefer><family>JetBrains Mono</family></prefer></alias>
  <alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Color Emoji</family></prefer></alias>
</fontconfig>
EOF

    write_if_needed "$HOME/.Xresources" "Xft.dpi: 96\nXft.autohint: 1\nXft.lcdfilter: lcddefault\nXft.hintstyle: hintfull\nXft.antialias: 1\nXft.rgba: rgb"
    xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
}

configure_desktop_basics() {
    configure_vscodium
    configure_nemo_thumbnails
    configure_nemo_engrampa_actions
    configure_fontconfig_xresources
}
