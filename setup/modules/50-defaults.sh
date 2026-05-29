setup_defaults() {
    echo_msg "⚙️  Configurando defaults..."

    # Terminal por defecto (Cinnamon)
    gsettings set org.cinnamon.desktop.default-applications.terminal exec 'kitty' 2>/dev/null || true

    # Nomacs por defecto para imagenes
    xdg-mime default org.nomacs.ImageLounge.desktop image/jpeg
    xdg-mime default org.nomacs.ImageLounge.desktop image/png
    xdg-mime default org.nomacs.ImageLounge.desktop image/gif
    xdg-mime default org.nomacs.ImageLounge.desktop image/bmp
    xdg-mime default org.nomacs.ImageLounge.desktop image/webp
    xdg-mime default org.nomacs.ImageLounge.desktop image/tiff

    echo_ok "✅ Defaults aplicados"
}
