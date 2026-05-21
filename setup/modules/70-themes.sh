setup_themes() {
    echo_msg "🎨 Temas COMPLETOS..."

    local xres_content="Xcursor.theme: $THEME_CURSOR_CLEAN
Xcursor.size: $CURSOR_SIZE_CLEAN"
    write_if_needed "$HOME/.Xresources" "$xres_content"
    xrdb -merge "$HOME/.Xresources" 2>/dev/null || true

    # Default cursor universal
    mkdir -p "$HOME/.icons/default"
    local default_theme="[Icon Theme]
Inherits=$THEME_CURSOR_CLEAN"
    write_if_needed "$HOME/.icons/default/index.theme" "$default_theme"

    # Variables entorno PERMANENTES
    mkdir -p "$HOME/.config/environment.d"
    local env_content="XCURSOR_THEME=$THEME_CURSOR_CLEAN
XCURSOR_SIZE=$CURSOR_SIZE_CLEAN
XCURSOR_PATH=$HOME/.icons:/usr/share/icons"
    write_if_needed "$HOME/.config/environment.d/cursor.conf" "$env_content"

    # GTK 3/4 (CORREGIDO: Faltaban el signo = y el valor correcto)
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"

    local gtk3_content="[Settings]
gtk-theme-name=$THEME_DEFAULT
gtk-icon-theme-name=$THEME_ICONS
gtk-cursor-theme-name=$THEME_CURSOR_CLEAN
gtk-cursor-theme-size=$CURSOR_SIZE_CLEAN
gtk-font-name=$THEME_FONT
gtk-application-prefer-dark-theme=true
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
gtk-xft-rgba=rgb"

    local gtk4_content="[Settings]
gtk-theme-name=$THEME_DEFAULT
gtk-icon-theme-name=$THEME_ICONS
gtk-cursor-theme-name=$THEME_CURSOR_CLEAN
gtk-cursor-theme-size=$CURSOR_SIZE_CLEAN
gtk-font-name=$THEME_FONT"

    write_if_needed "$HOME/.config/gtk-3.0/settings.ini" "$gtk3_content"
    write_if_needed "$HOME/.config/gtk-4.0/settings.ini" "$gtk4_content"

    # dconf GNOME/Cinnamon/MATE (CORREGIDO: Comillas GVariant)
    local themes=(gnome cinnamon mate)
    local dconf_paths=(
        "/org/gnome/desktop/interface/"
        "/org/cinnamon/desktop/interface/"
        "/org/mate/interface/"
    )

    for i in "${!themes[@]}"; do
        local de="${themes[$i]}"
        local path="${dconf_paths[$i]}"

        # GVariant requiere que las cadenas estén entre comillas simples DENTRO de las dobles
        # EJEMPLO CORRECTO: "'valor'"

        dconf_write_if_needed "${path}gtk-theme" "'$THEME_DEFAULT'"
        dconf_write_if_needed "${path}icon-theme" "'$THEME_ICONS'"
        dconf_write_if_needed "${path}cursor-theme" "'$THEME_CURSOR'"
        dconf_write_if_needed "${path}gtk-key-theme" "'Default'"
    done

    # WM themes (CORREGIDO)
    dconf_write_if_needed "/org/cinnamon/desktop/wm/preferences/theme" "'$THEME_DEFAULT'"
    dconf_write_if_needed "/org/cinnamon/desktop/wm/preferences/theme-backup" "'$THEME_DEFAULT'"
    dconf_write_if_needed "/org/gnome/desktop/wm/preferences/theme" "'$THEME_DEFAULT'"

    # Extras
    #dconf_write_if_needed "/org/blueberry/use-symbolic-icons" "false"
    dconf_write_if_needed "/org/gnome/desktop/interface/color-scheme" "'prefer-dark'"

    # LightDM (slick-greeter) (CORREGIDO)
    sudo -u lightdm dbus-launch dconf write "/x/dm/slick-greeter/cursor-theme-name" "'$THEME_CURSOR'" 2>/dev/null || true
    sudo -u lightdm dbus-launch dconf write "/x/dm/slick-greeter/icon-theme-name" "'$THEME_ICONS'" 2>/dev/null || true
    sudo -u lightdm dbus-launch dconf write "/x/dm/slick-greeter/theme-name" "'$THEME_DEFAULT'" 2>/dev/null || true

    # Iconos Rojos (Papirus)
    wget -qO- https://git.io/papirus-folders-install | sh
    papirus-folders -C red --theme Papirus-Dark

    # GTK para root (aplica tema a apps root como gufw)
    if [[ $EUID -ne 0 ]]; then
    sudo mkdir -p /root/.config/gtk-3.0
    sudo tee /root/.config/gtk-3.0/settings.ini >/dev/null << EOF
[Settings]
gtk-theme-name=$THEME_DEFAULT
gtk-application-prefer-dark-theme=1
EOF
    fi

    # Minimalist nvim
    curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # 6. Finalización
    xdg-user-dirs-update
    gsettings set org.cinnamon.desktop.default-applications.terminal exec 'kitty'
    sudo ln -s $(which pnpm) /usr/local/bin/npm
    echo_ok "🎨 Configuración de Monitores y Temas OK"
}
