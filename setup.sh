#!/bin/bash

# =============================================================================
# Autor: NeTenebrae | @NeTenebraes
# Descripción: neBSPWN Setup
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETUP_DIR="$SCRIPT_DIR/setup"
export SETUP_ROOT="$SCRIPT_DIR"

source "$SETUP_DIR/lib/helpers.sh"

source "$SETUP_DIR/config/themes.sh"
source "$SETUP_DIR/config/packages.sh"

source "$SETUP_DIR/modules/10-prereq.sh"
source "$SETUP_DIR/modules/30-packages.sh"
source "$SETUP_DIR/modules/40-repo.sh"
source "$SETUP_DIR/modules/50-defaults.sh"

source "$SETUP_DIR/modules/60-dotfiles.sh"
source "$SETUP_DIR/modules/70-themes.sh"
source "$SETUP_DIR/modules/80-zsh.sh"
source "$SETUP_DIR/modules/85-qt.sh"
source "$SETUP_DIR/modules/90-sddm.sh"
source "$SETUP_DIR/modules/95-lock.sh"
source "$SETUP_DIR/modules/96-fonts.sh"
source "$SETUP_DIR/modules/99-cleanup.sh"

main() {
    [ "$EUID" -eq 0 ] && { echo "❌ No root"; exit 1; }

    echo_msg "🚀 neBSPWN Setup $(date +'%H:%M')"

    check_internet
    ensure_aur_helper
    install_pacman_packages
    install_aur_packages
    configure_desktop_basics

    ensure_repo

    backup_config
    deploy_dotfiles
    setup_themes
    setup_defaults
    setup_zsh
    setup_qt
    setup_sddm
    install_betterlockscreen_lock
    setup_fonts_locale
    cleanup_temp_repo

    echo_ok "🎉 ¡LISTO! Reinicia: systemctl reboot"
}

<<<<<<< HEAD
# Escribe el contenido solo si es necesario, creando el directorio padre si falta
write_if_needed() {
    local file="$1"
    local content="$2"
    
    if ! check_file_content "$file" "$content"; then
        mkdir -p "$(dirname "$file")"
        echo -e "$content" > "$file"
        echo_ok "Actualizado: $file"
    else
        echo_skip "Sin cambios: $file"
    fi
}

# Escribe en dconf solo si el valor actual es distinto (evita reinicios innecesarios de servicios)
dconf_write_if_needed() {
    local key="$1"
    local value="$2"
    
    # Obtenemos el valor actual. Si falla, devolvemos un string vacío
    local current_val
    current_val=$(dconf read "$key" 2>/dev/null | sed "s/^'//;s/'$//" || echo "")
    
    # Limpiamos el valor de entrada para la comparativa (quitar comillas si vienen)
    local clean_value=$(echo "$value" | sed "s/^'//;s/'$//")

    if [[ "$current_val" != "$clean_value" ]]; then
        # Aquí dconf write sí necesita las comillas si es un string
        dconf write "$key" "$value"
        echo_ok "dconf: $key ➔ $value"
    else
        echo_skip "dconf OK: $key"
    fi
}

setup_dependecies() {
    # 0. Verificación de Internet
    echo_msg "🌐 Comprobando conexión a internet..."
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        echo_err "No hay conexión a internet. El script requiere acceso para instalar paquetes y temas."
        exit 1
    fi    
    echo_ok "Conexión activa"

    echo -e "\nSelecciona el idioma del sistema:"
    echo "1) Inglés | 2) Español LATAM | 3) Español España"
    read -r -p "Opción [1]: " choice
    case ${choice:-1} in
      1) export SYS_LANG="en_US.UTF-8" ;;
      2) export SYS_LANG="es_MX.UTF-8" ;;
      3) export SYS_LANG="es_ES.UTF-8" ;;
      *) export SYS_LANG="en_US.UTF-8" ;;
    esac
    echo_ok "Idioma seleccionado: $SYS_LANG"

# --- LÓGICA AUR HELPER: DETECTAR O INSTALAR ---
helpers=("yay-bin" "paru" "yay")
AUR_HELPER=""

# 1. Intentar detectar un helper ya instalado
for h in "paru" "yay"; do
    if command -v "$h" >/dev/null; then
        AUR_HELPER="$h"
        break
    fi
done

if [[ -n "$AUR_HELPER" ]]; then
    echo_ok "Se detectó '$AUR_HELPER' instalado."
    read -r -p "¿Deseas seguir usando $AUR_HELPER? [S/n]: " keep_existing
    [[ "$keep_existing" =~ ^([nN][oO]|[nN])$ ]] && AUR_HELPER=""
fi

# 2. Si no hay ninguno o el usuario decidió cambiarlo
if [[ -z "$AUR_HELPER" ]]; then
    echo -e "\n--- Instalación de AUR Helper ---"
    PS3="Selecciona cuál deseas instalar: "
    select opt in "${helpers[@]}" "Cancelar"; do
        case $opt in
            "yay-bin"|"paru"|"yay")
                # Si había uno anterior, lo quitamos para no tener conflictos
                # Buscamos si existe algun binario para borrarlo antes
                for old in "paru" "yay"; do
                    if command -v "$old" >/dev/null; then
                        echo_msg "Eliminando $old antiguo..."
                        sudo pacman -Rs --noconfirm "$old"
                    fi
                done

                echo_msg "Instalando $opt..."
                sudo pacman -S --needed --noconfirm base-devel git
                
                build_dir=$(mktemp -d)
                git clone "https://aur.archlinux.org/$opt.git" "$build_dir"
                (cd "$build_dir" && makepkg -si --noconfirm)
                rm -rf "$build_dir"

                AUR_HELPER="${opt%-bin}"
                break
                ;;
            "Cancelar")
                echo_err "No se seleccionó ningún AUR Helper. Saliendo..."
                exit 1
                ;;
            *) echo "Opción no válida";;
        esac
    done
fi

export AUR_HELPER
echo_ok "Usando $AUR_HELPER para el resto de la instalación."

    # ----------------------------------
    # 2. Dependencias Esenciales Pacman
    echo_msg "📦 Instalando dependencias esenciales (Pacman)..."
    sudo pacman -S --needed --noconfirm "${PKGS_PACMAN_Essencials[@]}"

    # 3. Dependencias Opcionales Pacman
    read -r -p "¿Instalar opcionales de Pacman? (${PKGS_PACMAN_optionals[*]}) (y/N): " resp_p
    [[ "$resp_p" =~ ^([yY][eE][sS]|[yY])$ ]] && sudo pacman -S --needed --noconfirm "${PKGS_PACMAN_optionals[@]}"

    # 4. PAQUETES AUR ESENCIALES
    echo_msg "📦 Instalando paquetes AUR con $AUR_HELPER..."
    "$AUR_HELPER" -S --needed --noconfirm "${PKGS_AUR[@]}"

    # 5. PAQUETES AUR OPCIONALES (CORREGIDO)
    read -r -p "¿Instalar opcionales de AUR? (${PKGS_AUR_Optionals[*]}) (y/N): " resp_a
    if [[ "$resp_a" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        "$AUR_HELPER" -S --needed --noconfirm "${PKGS_AUR_Optionals[@]}"
    fi

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

# 7. GESTIÓN INTELIGENTE DEL REPO
echo_msg "📥 GESTIONANDO REPO DOTFILES..."
local tmp_repo="/tmp/neBSPWN-dotfiles"
local current_dir=$(pwd)
local skip_clone=false

# ¿Estamos ya dentro del repo de dotfiles?
if git rev-parse --is-inside-work-tree &>/dev/null; then
    local remote_url=$(git remote get-url origin 2>/dev/null || echo "")
    # Buscamos la coincidencia del nombre del repo, no la URL exacta
    if [[ "$remote_url" == *"NeTenebraes/neBSPWN-dotfiles"* ]]; then
        echo -e "\n✨ DETECTADO: Ya estás dentro del directorio del repositorio."
        read -r -p "¿Usar los archivos de esta carpeta actual? (Y/n): " use_local
        if [[ ! "$use_local" =~ ^([nN][oO]|[nN])$ ]]; then
            export NE_TMP_REPO="$current_dir"
            echo_ok "Usando archivos locales: $NE_TMP_REPO"
            skip_clone=true # Marcamos para no clonar, pero seguimos la función
        fi
    fi
fi

# Solo entra aquí si NO estamos ya en el repo localmente
if [ "$skip_clone" = false ]; then
    if [[ -d "$tmp_repo" ]]; then
        echo -e "\n📂 Repo temporal ya existe en $tmp_repo"
        echo "  1) Actualizar (git pull) | 2) Mantener | 3) Re-clonar"
        read -r -p "Opción [1-3]: " repo_action
        case "$repo_action" in
            1) cd "$tmp_repo" && git pull && cd - >/dev/null ;;
            3) rm -rf "$tmp_repo" && git clone "$DOTFILES_REPO" "$tmp_repo" ;;
        esac
    else
        echo_msg "📥 Clonando repo en temporal..."
        git clone "$DOTFILES_REPO" "$tmp_repo"
    fi
    export NE_TMP_REPO="$tmp_repo"
fi

echo_ok "Ruta de trabajo establecida en: $NE_TMP_REPO"

    export NE_TMP_REPO="$tmp_repo"
    echo_ok "Fuentes + Repo OK"
}

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
    

    # Generar el script de emulación de npm para filtrar argumentos incompatibles
    mkdir -p $HOME/.local/bin/
    cat << 'EOF' > "$HOME/.local/bin/npm"
#!/usr/bin/env bash
set -euo pipefail

readonly EMULATED_NPM_VERSION="11.4.1"

if [[ $# -eq 0 ]]; then exit 1; fi

COMMAND=$1
shift

case "$COMMAND" in
  version) echo "{\"npm\":\"$EMULATED_NPM_VERSION\"}"; exit 0 ;;
  --version) echo "$EMULATED_NPM_VERSION"; exit 0 ;;
  init)
    # Filtra --yes y --scope que pnpm no reconoce
    pnpm init --silent
    echo "preferSymlinkedExecutables: true" > pnpm-workspace.yaml
    exit 0
    ;;
  exec)
    args=()
    for arg in "$@"; do
      [[ "$arg" != "--yes" ]] && args+=("$arg")
    done
    pnpm exec "${args[@]}"
    exit 0
    ;;
  install|add)
    pnpm_args=()
    packages=()
    is_global=0
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -g|--global) is_global=1 ;;
        --save-dev|--save-prod|--no-save) pnpm_args+=("$1") ;;
        -*) pnpm_args+=("$1") ;;
        *) packages+=("$1") ;;
      esac
      shift
    done
    [[ $is_global -eq 1 ]] && pnpm_args+=("--global")
    if [[ ${#packages[@]} -gt 0 ]]; then
      pnpm add "${pnpm_args[@]}" "${packages[@]}"
    else
      pnpm install "${pnpm_args[@]}"
    fi
    exit 0
    ;;
  *) pnpm "$COMMAND" "$@";;
esac
EOF

# Asignar permisos de ejecución al script
    chmod +x "$HOME/.local/bin/npm"
    echo_ok "🎨 Configuración de Monitores y Temas OK"
}

# 🌀 Función SDDM Modularizada (Integrada)
setup_sddm() {
    echo_msg "🌀 Iniciando módulo SDDM..."

    # Variables Locales
    local THEME_DEST_NAME="netenebrae"
    local THEMES_DIR="/usr/share/sddm/themes"
    local TARGET_DIR="$THEMES_DIR/$THEME_DEST_NAME"
    local METADATA="$TARGET_DIR/metadata.desktop"
    local CLONE_DIR="${NE_TMP_REPO:-/tmp/neBSPWN-dotfiles}"
    local DATE=$(date +%s)

    # 1. Dependencias SDDM (Aseguramos que estén, aunque setup_dependencies ya instala sddm)
    # Qt6 es vital para este tema específico
    echo_msg "📦 Verificando dependencias Qt6 para SDDM..."
    sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg qt6-declarative 2>/dev/null || echo_skip "Deps ya instaladas"

    # 2. Localizar archivos en el repo clonado
    local source_path=""
    
    if [[ -f "$CLONE_DIR/SDDM/metadata.desktop" ]]; then
        source_path="$CLONE_DIR/SDDM"
    elif [[ -f "$CLONE_DIR/repo/SDDM/metadata.desktop" ]]; then
        source_path="$CLONE_DIR/repo/SDDM"
    else
        local found=$(find "$CLONE_DIR" -type f -name "metadata.desktop" | grep "SDDM" | head -n 1)
        if [[ -n "$found" ]]; then
            source_path=$(dirname "$found")
        else
            echo_err "❌ No se encontró la carpeta del tema SDDM en $CLONE_DIR"
            return 1
        fi
    fi

    echo_ok "Fuente encontrada: $source_path"

    # 3. Instalación Limpia
    if [[ -d "$TARGET_DIR" ]]; then
        echo_msg "♻️  Removiendo tema anterior..."
        sudo rm -fr "$TARGET_DIR"
    fi
    
    sudo mkdir -p "$TARGET_DIR"
    echo_msg "📂 Copiando archivos a $TARGET_DIR..."
    sudo cp -r "$source_path"/* "$TARGET_DIR"/

    # Fuentes
    if [[ -d "$TARGET_DIR/Fonts" ]]; then
        echo_msg "🅰️  Instalando fuentes..."
        sudo cp -r "$TARGET_DIR/Fonts"/* /usr/share/fonts/
        fc-cache -f
    fi

    # Configuración Base SDDM
    sudo mkdir -p /etc/sddm.conf.d
    echo "[Theme]
Current=$THEME_DEST_NAME" | sudo tee /etc/sddm.conf >/dev/null

    echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf >/dev/null

    # 4. Configurar Black Hole (Core Logic)
    if [[ ! -f "$METADATA" ]]; then
        echo_err "❌ Error crítico: metadata.desktop no encontrado tras copia."
        return 1
    fi
    
    echo_msg "⚫ Configurando Tema"
    # Forzamos la configuración
    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/netenebrae.conf|" "$METADATA"
    
    # 5. Parche QML de compatibilidad (Heredado de tu script anterior por seguridad)
    local qml_file="$TARGET_DIR/Main.qml"
    if [[ -f "$qml_file" ]]; then
        # Solo aplicamos si detectamos que faltan versiones (seguro simple)
        if ! grep -q "QtQuick 2.15" "$qml_file"; then
             echo_msg "💉 Parcheando imports QML..."
             sudo sed -i 's/^import QtQuick$/import QtQuick 2.15/' "$qml_file"
             sudo sed -i 's/^import QtQuick.Layouts$/import QtQuick.Layouts 1.15/' "$qml_file"
             sudo sed -i 's/^import QtQuick.Controls$/import QtQuick.Controls 2.15/' "$qml_file"
        fi
    fi

    # 6. Habilitar Servicio
    if ! systemctl is-enabled sddm &>/dev/null; then
        echo_msg "🔌 Habilitando servicio SDDM..."
        sudo systemctl enable sddm
    fi

    echo_ok "✅ SDDM Listo"
}

setup_zsh() {
    echo_msg "Configurando ZSH + Starship para $USER y Root..."

    # 1. Cambiar shell a ZSH para el usuario actual
    if [[ "$SHELL" != "/usr/bin/zsh" ]]; then
        chsh -s /usr/bin/zsh
        echo_ok "ZSH configurado para $USER"
    fi

    # 2. Instalar Starship si no existe
    if ! command -v starship >/dev/null 2>&1; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        echo_ok "Starship instalado globalmente"
    else
        echo_skip "Starship ya está instalado"
    fi

    # 3. Configurar el archivo .zshrc para el usuario actual
    if ! grep -q 'starship init zsh' ~/.zshrc; then
        echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        echo_ok "Starship añadido al .zshrc de $USER"
    fi

    # --- INTEGRACIÓN PARA ROOT ---
    echo_msg "Sincronizando configuración con Root..."

    # Cambiar shell de root a ZSH
    sudo chsh -s /usr/bin/zsh root

    # Crear directorio de config para root si no existe
    sudo mkdir -p /root/.config

    # Enlazar simbólicamente tu config actual a la de root
    # Así, si editas tu config, la de root se actualiza sola.
    sudo ln -sf "$HOME/.config/starship.toml" /root/.config/starship.toml

    # Añadir inicialización al .zshrc de root
    if ! sudo grep -q 'starship init zsh' /root/.zshrc 2>/dev/null; then
        echo 'eval "$(starship init zsh)"' | sudo tee -a /root/.zshrc > /dev/null
        echo_ok "Starship añadido al .zshrc de Root"
    fi

    echo_ok "ZSH y Starship listos en ambos usuarios"
}

deploy_dotfiles() {
    echo_msg "🚀 Deploy dotfiles DESTRUCTIVO..."
    local tmp_repo="${NE_TMP_REPO:-/tmp/neBSPWN-dotfiles}"
    local config_src="$tmp_repo/Config Files"
    local home_src="$tmp_repo/Home files"

    if [[ -d "$config_src" ]]; then
        echo_msg "📁 Config Files → ~/.config/"
        mkdir -p "$HOME/.config"
        shopt -s dotglob nullglob
        for item in "$config_src"/*; do
            [[ ! -e "$item" ]] && continue
            local name="$(basename "$item")"
            local target="$HOME/.config/$name"
            
            if [[ -e "$target" ]]; then
                rm -rf "$target"
                echo_msg "🔥 Borrado: $name"
            fi
            
            cp -rf "$item" "$target"
            echo_ok "📥 Instalado: $name"
        done
        shopt -u dotglob nullglob
    fi

    # HOME FILES -> ~/ (BORRA Y REEMPLAZA)
    if [[ -d "$home_src" ]]; then
        echo_msg "🏠 Home Files → ~/"
        shopt -s dotglob nullglob
        for item in "$home_src"/*; do
            [[ ! -e "$item" ]] && continue
            local name="$(basename "$item")"
            local target="$HOME/$name"
            
            if [[ -e "$target" ]]; then
                rm -rf "$target"
                echo_msg "🔥 Borrado: $name"
            fi
            
            cp -rf "$item" "$target"
            echo_ok "📥 Instalado: $name"
        done
        shopt -u dotglob nullglob
    fi
    
    echo_ok "🚀 Dotfiles 100% Sincronizados (Modo Dios)"
}

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
local kvantum_theme=$(echo "$THEME_DEFAULT" | sed 's|-standard\+.*||' | sed 's|-hdpi||' | sed 's|-xhdpi||')
echo_msg "🌑 GTK '$THEMEDEFAULT' → Kvantum '$kvantum_theme'"


    # 4. Iniciar servicios de Portal (Run-time fix para la sesión actual)
    if ! pgrep -f "xdg-desktop-portal" >/dev/null; then
        echo_msg "🔌 Iniciando Portals (Sesión actual)..."
        /usr/lib/xdg-desktop-portal & disown
        /usr/lib/xdg-desktop-portal-gtk & disown
    fi

    echo_ok "✅ Entorno Qt completado"
}

# Función para instalar lock.png de betterlockscreen usando variables existentes
install_betterlockscreen_lock() {
    echo_msg "🔒 Configurando Betterlockscreen Lock..."
    
    local IMAGE_REL_PATH="Config Files/bspwm/lock.png"
    local tmp_repo="${NE_TMP_REPO:-/tmp/neBSPWN-dotfiles}"
    local SRC_PATH="$tmp_repo/$IMAGE_REL_PATH"
    
    # Verificar imagen
    if [[ ! -f "$SRC_PATH" ]]; then
        echo_err "Imagen no encontrada: $SRC_PATH"
        return 1
    fi
    
# Instalar si falta
    if ! command -v betterlockscreen >/dev/null 2>&1; then
        echo_msg "📦 Instalando betterlockscreen usando $AUR_HELPER..."
        "$AUR_HELPER" -S --needed --noconfirm betterlockscreen
    fi
    
    local DEST_DIR="$HOME/.config/betterlockscreen/rc"
    mkdir -p "$DEST_DIR"
    cp -f "$SRC_PATH" "$DEST_DIR/lock.png"
    chmod 644 "$DEST_DIR/lock.png"
    
    # ✅ CONFIGURACIÓN AUTOMÁTICA (esto faltaba)
    local rc_file="$DEST_DIR/rc"
    cat > "$rc_file" << 'EOF'
# neBSPWN Betterlockscreen - Catppuccin Mocha
bg-fill=0
bg-color=#1e1e2e
bg-image=$HOME/.config/betterlockscreen/rc/lock.png
lock-text="Bloqueado"
text-color=#cdd6f4
ring-color=#cdd6f4
key-hl-color=#f38ba8
bshl-color=#f38ba8
separator-color=000000
inside-color=#1e1e2e
line-uses-inside=1
line-color=#45475a
insidever-color=#45475a
ringver-color=#45475a
key-color=#45475a
verif-text=""
time-color=#cdd6f4
time-size=90
time-font=sans-serif
auth-color=#cdd6f4
auth-size=60
auth-font=sans-serif
EOF
    
    echo_ok "✅ Config: $rc_file"
    
    # ✅ APLICA EL LOCK AUTOMÁTICAMENTE
    echo_msg "🔐 Probando lock AUTOMÁTICO..."
    betterlockscreen -u "$DEST_DIR/lock.png"
    
    # ✅ HOTKEY para sxhkd (Super + L)
    local sxhkdrc="$HOME/.config/sxhkd/sxhkdrc"
    if [[ -f "$sxhkdrc" ]] && ! grep -q "betterlockscreen" "$sxhkdrc"; then
        {
            echo ""
            echo "# 🔒 Lock screen (Super + L)"
            echo "super + l"
            echo "    betterlockscreen -l dimblur"
        } >> "$sxhkdrc"
        echo_ok "Hotkey Super+L agregada a sxhkdrc"
        pkill -USR1 sxhkd 2>/dev/null || true
    fi
    
    echo_ok "🎉 Betterlockscreen COMPLETO (Super+L para bloquear)"
}

# Agregar DESPUÉS de la función install_betterlockscreen_lock() { ... }

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

backup_config() {
    echo_msg "💾 Backup de .config (OPCIONAL)..."
    
    local CONFIG_DIR="$HOME/.config"
    local BACKUP_DIR="$HOME/.config.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [[ ! -d "$CONFIG_DIR" ]]; then
        echo_skip ".config no existe (nada que respaldar)"
        return 0
    fi
    
    echo -e "\n⚠️  ¿Hacer backup de .config ANTES de deploy?"
    echo "   → Se copiará a: $BACKUP_DIR"
    echo "   → Carpeta actual: $(du -sh "$CONFIG_DIR" 2>/dev/null || echo "~5MB")"
    echo -e "\n   (Y/n) ← Default NO"
    read -r -p " > " do_backup
    
    if [[ "$do_backup" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo_msg "📦 Creando backup → $BACKUP_DIR"
        cp -rf "$CONFIG_DIR" "$BACKUP_DIR"
        echo_ok "✅ Backup creado: $BACKUP_DIR"
        
        echo -e "\n💡 Para restaurar después:"
        echo "   cp -rf $BACKUP_DIR/* $CONFIG_DIR/"
        echo "   rm -rf $BACKUP_DIR  # (opcional)"
        
    else
        echo_skip "Backup saltado (.config se sobrescribirá)"
    fi
}

# 🚀 EJECUCIÓN
[ "$EUID" -eq 0 ] && { echo "❌ No root"; exit 1; }

echo_msg "🚀 neBSPWN Setup DESTRUCTIVO $(date +'%H:%M')"
echo_msg "   Integración SDDM Black Hole Edition"

sudo pacman -Syu --noconfirm


setup_dependecies
backup_config
deploy_dotfiles
setup_themes
setup_zsh
setup_qt
setup_sddm
install_betterlockscreen_lock
setup_fonts_locale


# Limpieza final
# ✅ DESPUÉS (pregunta confirmación)
if [[ -n "${NE_TMP_REPO:-}" && -d "$NE_TMP_REPO" ]]; then
    echo -e "\n🗑️  ¿Borrar repo temporal? ($NE_TMP_REPO)"
    echo "   (Útil para debuggear betterlockscreen, SDDM, etc.) (y/N)"
    read -r -p " > " delete_repo
    if [[ "$delete_repo" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        rm -rf "$NE_TMP_REPO"
        echo_ok "🗑️  Repo temporal borrado"
    else
        echo_skip "Manteniendo repo temporal: $NE_TMP_REPO"
    fi
fi


echo_ok "🎉 ¡LISTO! Reinicia: systemctl reboot"
=======
main "$@"
>>>>>>> setup_reestruc
