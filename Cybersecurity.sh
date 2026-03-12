#!/bin/bash

# ==================== CONFIGURACIÓN CENTRALIZADA ====================
set -euo pipefail

# 🌐 URLs y Recursos Críticos
BURP_URL="https://portswigger.net/burp/releases/download?product=community&version=2025.11.6&type=Linux"
CAIDO_GITHUB_API="https://api.github.com/repos/caido/caido/releases/latest"
CAIDO_BASE_URL="https://caido.download/releases"
CAIDO_ICON_URL="https://cdn.brandfetch.io/idFdZwH_n_/w/500/h/500/theme/dark/logo.png?c=1bxid64Mup7aczewSAYMX&t=1764981790594"
AUR_REPO="https://aur.archlinux.org/paru-bin.git"

# 📦 Paquetes por Categoría
PKGS_VIRTUALBOX=("virtualbox" "virtualbox-host-dkms")
PKGS_VMWARE=("fuse2" "dkms" "libcanberra" "gtkmm3" "gst-plugins-base-libs" "pcsclite")
AUR_VMWARE=("vmware-keymaps" "vmware-workstation")

# 📁 Rutas del Sistema
REALUSER="${SUDO_USER:-${USER}}"
if [[ $EUID -eq 0 ]]; then
    REALUSER="$(logname 2>/dev/null || whoami)"
fi
USERHOME="$(getent passwd "$REALUSER" | cut -d: -f6)"
CFG_FIREJAIL="$USERHOME/.config/firejail"
APP_DIR="$USERHOME/.local/share/applications"

# 🎨 Colores y Logging
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log_ok()  { echo "[OK] $1"; }
log_msg() { echo "[MSG] $1"; }
log_err() { echo "[ERR] $1" >&2; }


# ==================== FUNCIONES UTILITARIAS ====================
detect_kernel_headers() {
    local KERNEL=$(uname -r | sed 's/\([0-9]\+\.[0-9]\+\.[0-9]\+\)-\(.*\)/\2/')
    case "$KERNEL" in
        *-hardened*) echo "linux-hardened-headers" ;;
        *-zen*)      echo "linux-zen-headers" ;;
        *-lts*)      echo "linux-lts-headers" ;;
        *)           echo "linux-headers" ;;
    esac
}

KERNEL_HEADERS=$(detect_kernel_headers)
log_msg "Kernel detectado: $(uname -r) → Usando: $KERNEL_HEADERS"

check_cmd() { command -v "$1" &>/dev/null; }

# ==================== AUR HELPER ====================
install_aur_helper() {
    if check_cmd paru; then
        log_ok "paru ✅ YA INSTALADO (preferido)" >&2  # <--- Agregado >&2
        echo "paru"
        return 0
    elif check_cmd yay; then
        log_ok "yay ✅ YA INSTALADO (alternativa)" >&2 # <--- Agregado >&2
        echo "yay"
        return 0
    fi
    
    log_msg "Instalando paru..." >&2
    cd /tmp || exit 1
    git clone "$AUR_REPO"
    cd paru-bin && makepkg -si --noconfirm
    cd - &>/dev/null
    log_ok "paru instalado" >&2
    echo "paru"
}

aur_install() {
    local AUR_HELPER
    AUR_HELPER="$(install_aur_helper)"
    log_msg "Instalando paquetes AUR: $*"

    if ! "$AUR_HELPER" -S --noconfirm "$@"; then
        log_err "Fallo instalando algunos paquetes AUR: $*"
        return 1
    fi

    log_ok "AUR completado: $*"
}

# ==================== INSTALADORES DE VM ====================


# ==================== INSTALADORES DE VM ====================
install_vmware() {
    local TITLE="VMware Workstation"

    if check_cmd vmware; then
        log_ok "$TITLE YA INSTALADO"
        return 0
    fi

    log_msg "PREPARANDO $TITLE para kernel hardened..."

    # Dependencias de repo
    local PKGS_VMWARE_EXT=("${PKGS_VMWARE[@]}" "$KERNEL_HEADERS")
    sudo pacman -S --noconfirm --needed "${PKGS_VMWARE_EXT[@]}"

    # Paquetes AUR (usa aur_install, NO llames install_aur_helper aquí)
    log_msg "Instalando paquetes AUR: ${AUR_VMWARE[*]}"
    if ! aur_install "${AUR_VMWARE[@]}"; then
        log_err "VMware desde AUR falló. Revisa: ${AUR_VMWARE[*]}"
        return 1
    fi

    # Verificar binario
    if ! check_cmd vmware; then
        log_err "$TITLE no instalado correctamente"
        return 1
    fi

    sudo systemctl daemon-reload
    systemctl list-unit-files vmware-networks.service &>/dev/null && \
        sudo systemctl enable vmware-networks.service vmware-usbarbitrator.service

    sudo vmware-modconfig --console --install-all || true
    log_ok "$TITLE ✅ OK. Ejecuta 'vmware' para setup inicial"
}




install_virtualbox() {
    local TITLE="VirtualBox"
    if check_cmd virtualbox && lsmod | grep -q vboxdrv && ip link show vboxnet0 &>/dev/null; then
        log_ok "$TITLE + RED ✅ YA FUNCIONANDO"
        return 0
    fi
    local PKGS=("${PKGS_VIRTUALBOX[@]}" "$KERNEL_HEADERS")
    log_msg "Instalando: ${PKGS[*]}"
    if ! check_cmd virtualbox; then
        sudo pacman -S --needed --noconfirm "${PKGS[@]}"
    else
        sudo pacman -S --noconfirm virtualbox-host-dkms "$KERNEL_HEADERS"
    fi
    sudo dkms autoinstall --force
    sudo modprobe -r vboxnetadp vboxnetflt vboxdrv 2>/dev/null || true
    sudo modprobe vboxdrv vboxnetflt vboxnetadp
    sudo VBoxManage hostonlyif create 2>/dev/null || true
    sudo usermod -aG vboxusers "$REALUSER"
    create_vbox_service
    log_ok "$TITLE ✅ LISTO + AUTO-START"
}

create_vbox_service() {
    local SERVICE_FILE="/etc/systemd/system/vbox-modules.service"
    sudo systemctl stop vbox-modules.service 2>/dev/null || true
    sudo rm -f "$SERVICE_FILE"
    sudo tee "$SERVICE_FILE" > /dev/null << 'EOF'
[Unit]
Description=VirtualBox Kernel Modules
Before=graphical-session.target
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/dkms autoinstall --force
ExecStart=/usr/bin/modprobe vboxdrv vboxnetflt vboxnetadp
ExecStop=/usr/bin/modprobe -r vboxnetadp vboxnetflt vboxdrv
TimeoutSec=30

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable --now vbox-modules
    log_ok "✅ vbox-modules.service CREADO + ACTIVADO"
}

# ==================== BURP SUITE ====================
install_burp() {
    local TITLE="Burp Suite Community"
    
    # 🔍 DETECCIÓN MEJORADA (5 métodos ANTES de descargar)
    if [[ -x "$USERHOME/BurpSuiteCommunity/BurpSuiteCommunity" ]]; then
        log_ok "Burp detectado: ~/BurpSuiteCommunity ✓"
        create_burp_wrapper "$USERHOME/BurpSuiteCommunity/BurpSuiteCommunity"
        return 0
    fi
    
    if command -v burp &>/dev/null; then
        log_ok "Burp detectado: ~/.local/bin/burp ✓"
        return 0
    fi
    
    if pacman -Q burpsuite &>/dev/null 2>&1; then
        log_ok "Burp detectado: AUR (burpsuite) ✓"
        return 0
    fi
    
    if find "$USERHOME" -maxdepth 3 -name "*BurpSuite*" -type f -executable 2>/dev/null | grep -q .; then
        local BURP_EXIST=$(find "$USERHOME" -maxdepth 3 -name "*BurpSuite*" -type f -executable | head -1)
        log_ok "Burp detectado: $BURP_EXIST ✓"
        create_burp_wrapper "$BURP_EXIST"
        return 0
    fi
    
    if flatpak list | grep -q burp; then
        log_ok "Burp detectado: Flatpak ✓"
        return 0
    fi
    
    log_ok "Burp NO detectado → Instalando..."
    
    # DESCARGA SOLO si NO existe (ahorra 341MB)
    log_msg "📥 Descargando Burp Suite 2025.11.6 (341MB)..."
    mkdir -p "$USERHOME/Downloads" "$USERHOME/.local/bin"
    local BURP_SH="$USERHOME/Downloads/burpsuite_community_linux.sh"
    
    if command -v wget >/dev/null; then
        wget -O "$BURP_SH" "$BURP_URL" || { log_err "Fallo descarga"; return 1; }
    else
        curl -L -o "$BURP_SH" "$BURP_URL" || { log_err "Fallo descarga"; return 1; }
    fi
    
    # ... resto del código de instalación (igual que antes)
    chmod +x "$BURP_SH"
 
    cd "$USERHOME"
    _JAVA_AWT_WM_NONREPARENTING=1 \
    _JAVA_OPTIONS='-Dawt.toolkit.name=MToolkit' \
    QT_QPA_PLATFORM=xcb \
    timeout 600 "$BURP_SH" --auto-install || {
        log_err "Auto-install falló → Método manual..."
        # Método manual backup (igual que antes)
    }
    
    if [[ -x "$USERHOME/BurpSuiteCommunity/BurpSuiteCommunity" ]]; then
        create_burp_wrapper "$USERHOME/BurpSuiteCommunity/BurpSuiteCommunity"
        log_ok "✅ Burp 2025.11.6 → ~/.local/bin/burp"
    else
        log_err "❌ Instalación falló"
        return 1
    fi
}

create_burp_wrapper() {
    local BURPBIN="$1"
    local WRAPPER="$USERHOME/.local/bin/burp"
    mkdir -p "$USERHOME/.local/bin"
    cat > "$WRAPPER" << EOF
#!/bin/bash
export _JAVA_AWT_WM_NONREPARENTING=1
export _JAVA_OPTIONS='-Dawt.toolkit.name=MToolkit -Djava.security.manager=allow'
exec "$BURPBIN" "\$@"
EOF
    chmod +x "$WRAPPER"
    log_ok "Wrapper creado: $WRAPPER"
}

# ==================== CAIDO ====================
install_caido() {
    local DIR="$USERHOME/.local/share/ciber"
    local BINDIR="$USERHOME/.local/bin" 
    
    mkdir -p "$BINDIR" "$DIR" "$USERHOME/.local/share/applications" "$USERHOME/.local/share/icons"    
    log_msg "Configurando icono Caido..."
    wget -q "$CAIDO_ICON_URL" -O "$USERHOME/.local/share/icons/caido.png"

    # --- FIX PARA KERNEL HARDENED ---
    if [[ "$(uname -r)" == *"-hardened"* ]]; then
        log_msg "Detectado kernel hardened: Asegurando compatibilidad con Sandbox..."
        if [[ $(sysctl -n kernel.unprivileged_userns_clone) -eq 0 ]]; then
            sudo sysctl -w kernel.unprivileged_userns_clone=1
            echo 'kernel.unprivileged_userns_clone=1' | sudo tee /etc/sysctl.d/99-user-namespaces.conf > /dev/null
        fi
    fi
    
    cat > "$USERHOME/.local/share/applications/caido.desktop" << EOF
[Desktop Entry]
Version=1.0
Name=CaiDO
Comment=Web Security Testing Proxy
Exec=/home/$REALUSER/.local/bin/caido
Icon=caido
Terminal=false
Type=Application
Categories=Network;Security;Hacking;
StartupWMClass=Caido
MimeType=application/x-caido;
EOF
    update-desktop-database "$USERHOME/.local/share/applications"

    # Obtener versión y definir ruta de AppImage
    local CAIDOVERSION=$(curl -s "$CAIDO_GITHUB_API" | grep tag_name | sed -E 's/.*"([^"]+)".*/\1/')
    local CAIDOAPPIMAGE="$BINDIR/caido-desktop-${CAIDOVERSION}-linux-x86_64.AppImage"
    
    # Descargar si no existe
    if [[ ! -x "$CAIDOAPPIMAGE" ]]; then
        log_msg "DESCARGANDO Caido v$CAIDOVERSION..."
        rm -f "$BINDIR/caido-desktop-"*.AppImage
        wget --timeout=60 "${CAIDO_BASE_URL}/${CAIDOVERSION}/caido-desktop-${CAIDOVERSION}-linux-x86_64.AppImage" -O "$CAIDOAPPIMAGE"
        chmod +x "$CAIDOAPPIMAGE"
        echo "$CAIDOVERSION" > "$DIR/caidoversion.txt"
    fi
    
    # --- GESTIÓN DE ENLACES (CORREGIDA) ---
    # Borramos cualquier link previo para evitar el error de "too many levels"
    rm -f "$BINDIR/caido"
    
    # Creamos un único link: del nombre simple 'caido' al archivo AppImage real
    ln -sf "$CAIDOAPPIMAGE" "$BINDIR/caido"
    
    if ! grep -q ".local/bin" "$USERHOME/.bashrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$USERHOME/.bashrc"
    fi
    
    log_ok "Caido OK → caido / Rofi / Menú"
}

# ==================== FIREJAIL + NAVEGADORES ====================
detect_browser() {
    local browsers=()
    [[ $(command -v firefox) ]] && browsers+=("firefox")
    [[ $(command -v chromium) ]] && browsers+=("chromium") 
    [[ $(command -v brave-browser) ]] && browsers+=("brave")
    [[ $(command -v librewolf) ]] && browsers+=("librewolf")
    [[ $(command -v google-chrome) ]] && browsers+=("google-chrome")
    [[ $(command -v brave) ]] && browsers+=("brave")
    printf '%s\n' "${browsers[@]}"
}

install_firejail() {
    if check_cmd firejail; then
        log_ok "Firejail ya instalado"
        return 0
    fi
    log_msg "Instalando Firejail…"
    sudo pacman -S --needed --noconfirm firejail
    log_ok "Firejail instalado"
}

setup_firejail_global() {
    echo
    log_msg "🔥 ¿Firejail GLOBAL para apps básicas? (firefox→firejail firefox)"
    read -r -p "[y/N] " global_choice
    
    if [[ "$global_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [[ $EUID -eq 0 ]]; then
            sudo -u "$REALUSER" firecfg --fix
        else
            firecfg --fix
        fi
        log_ok "✅ Firejail GLOBAL activado"
    fi
}

setup_personal_browser() {
    local PERSONAL_BROWSER="$1"
    local FULL_FIREJAIL=$(which firejail)
    local FULL_BROWSER=$(which "$PERSONAL_BROWSER")
    local FULL_PROFILE="$CFG_FIREJAIL/${PERSONAL_BROWSER}-personal.profile"
    
    mkdir -p "$CFG_FIREJAIL" "$APP_DIR"

    # ✅ PERFIL VACÍO = Firejail 0.9.76 compatible
    # File picker funciona por NO bloquear /tmp
    touch "$FULL_PROFILE"

    # Launcher CON RUTAS ABSOLUTAS (ROFI OK)
    cat > "$APP_DIR/${PERSONAL_BROWSER}-personal-firejail.desktop" << EOF
[Desktop Entry]
Name=${PERSONAL_BROWSER^} (Personal)
Comment=${PERSONAL_BROWSER^} Firejail - File Uploads OK
Exec=$FULL_FIREJAIL --profile=$FULL_PROFILE $FULL_BROWSER %u
Icon=${PERSONAL_BROWSER}
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=${PERSONAL_BROWSER}
EOF

    # Hide original
    local LOCAL_DESKTOP="$APP_DIR/${PERSONAL_BROWSER}.desktop"
    cat > "$LOCAL_DESKTOP" << EOF
[Desktop Entry]
Type=Application
Name=${PERSONAL_BROWSER^} (hidden)
Exec=$FULL_BROWSER %u
Icon=${PERSONAL_BROWSER}
NoDisplay=true
EOF

    update-desktop-database "$APP_DIR" 2>/dev/null || true
    log_ok "${PERSONAL_BROWSER^} (Personal) ✓ ROFI + File Picker OK"
}

setup_bugbounty_browser() {
    local BUG_BROWSER="$1"
    local BB_PATH="$HOME/.bugbounty_browser_profile"
    local BB_DOWNLOADS="$HOME/Downloads/bugbounty_files"
    
    mkdir -p "$CFG_FIREJAIL" "$APP_DIR" "$BB_PATH" "$BB_DOWNLOADS"

    # 1. PREFS: Forzamos estabilidad en certificados y diálogos
    if [ ! -f "$BB_PATH/prefs.js" ]; then
        cat > "$BB_PATH/prefs.js" << EOF
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.page", 3);
user_pref("widget.use-xdg-desktop-portal.file-picker", 1);
user_pref("security.cert_pinning.enforcement_level", 1);
EOF
    fi

    # 2. PERFIL FIREJAIL (Permisos de Certificados y Estabilidad)
    cat > "$CFG_FIREJAIL/${BUG_BROWSER}-bugbounty.profile" << EOF
include firefox.profile

# AISLAMIENTO DE DATOS
blacklist \${HOME}/.mozilla/firefox
noblacklist ${BB_PATH}
whitelist ${BB_PATH}
noblacklist ${BB_DOWNLOADS}
whitelist ${BB_DOWNLOADS}

# --- FIX PARA IMPORTAR CERTIFICADOS ---
# Permitir que Firefox gestione su base de datos de seguridad
writable-run-user
ignore memory-deny-write-execute
ignore nodbus

# Comunicación necesaria para el selector de archivos (Certificado .der/.pem)
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.portal.Documents
dbus-user.talk org.freedesktop.FileChooser

# Acceso a librerías de seguridad del sistema
noblacklist /etc/ssl
noblacklist /etc/pki
EOF

    # 3. LANZADOR (Con variable de entorno para evitar el crash)
    cat > "$APP_DIR/${BUG_BROWSER}-bugbounty-firejail.desktop" << EOF
[Desktop Entry]
Name=${BUG_BROWSER^} (Bug Bounty)
Exec=env GTK_USE_PORTAL=1 firejail --profile=$CFG_FIREJAIL/${BUG_BROWSER}-bugbounty.profile $BUG_BROWSER --no-remote --profile ${BB_PATH} %u
Icon=${BUG_BROWSER}
Terminal=false
Type=Application
Categories=Network;WebBrowser;
StartupWMClass=firefox-bugbounty
EOF

    update-desktop-database "$APP_DIR" 2>/dev/null || true
}


configure_bugbounty_dns() {
    local BUG_BROWSER="$1"
    local PROFILE="$CFG_FIREJAIL/${BUG_BROWSER}-bugbounty.profile"

    echo
    log_msg "🌐 DNS para ${BUG_BROWSER^} Bug Bounty"
    echo "  1) Cloudflare (1.1.1.1) [recomendado]"
    echo "  2) Quad9 (9.9.9.9)"
    echo "  3) Google (8.8.8.8)"
    echo "  4) Sistema"
    read -r -p " > " dns_choice

    sed -i '/^dns /d' "$PROFILE"
    case "$dns_choice" in
        1) echo "dns 1.1.1.1" >> "$PROFILE" && echo "dns 1.0.0.1" >> "$PROFILE" && log_ok "Cloudflare ✓" ;;
        2) echo "dns 9.9.9.9" >> "$PROFILE" && echo "dns 149.112.112.112" >> "$PROFILE" && log_ok "Quad9 ✓" ;;
        3) echo "dns 8.8.8.8" >> "$PROFILE" && echo "dns 8.8.4.4" >> "$PROFILE" && log_ok "Google ✓" ;;
        *) log_msg "Sin DNS específico" ;;
    esac
}

setup_firejail_browsers() {
    install_firejail
    setup_firejail_global

    local AVAILABLE_BROWSERS=($(detect_browser))
    if [[ ${#AVAILABLE_BROWSERS[@]} -eq 0 ]]; then
        log_err "❌ No se detectó ningún navegador"
        return 1
    fi

    echo
    log_msg "🦊 Navegadores detectados:"
    printf '   %s\n' "${AVAILABLE_BROWSERS[@]}"
    echo

    read -r -p "¿Cuál usar como PERSONAL? " personal_choice
    if [[ ! " ${AVAILABLE_BROWSERS[*]} " =~ " $personal_choice " ]]; then
        log_err "Navegador no válido. Usando: ${AVAILABLE_BROWSERS[0]}"
        personal_choice="${AVAILABLE_BROWSERS[0]}"
    fi
    setup_personal_browser "$personal_choice"

    echo
    read -r -p "¿Quieres navegador BUG BOUNTY separado? [y/N] " bug_choice
    if [[ "$bug_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo
        log_msg "Elige navegador para BUG BOUNTY:"
        printf '   %s\n' "${AVAILABLE_BROWSERS[@]}"
        read -r -p " > " bug_choice_browser
        
        if [[ ! " ${AVAILABLE_BROWSERS[*]} " =~ " $bug_choice_browser " ]]; then
            log_err "Usando: ${AVAILABLE_BROWSERS[0]}"
            bug_choice_browser="${AVAILABLE_BROWSERS[0]}"
        fi
        
        setup_bugbounty_browser "$bug_choice_browser"
        configure_bugbounty_dns "$bug_choice_browser"
    fi

    echo
    log_ok "✅ ¡LISTO!"
    echo "rofi drun → '${personal_choice^} (Personal)' $( [[ "$bug_choice" =~ ^[yY] ]] && echo "| '${bug_choice_browser^} (Bug Bounty)'" )"
}

# ==================== FIREWALL + DNS ====================
setup_dns() {
    echo "------------------------------------------------"
    echo "🌐 CONFIGURACIÓN DNS PERSISTENTE (NM DISPATCHER)"
    echo "------------------------------------------------"
    echo "1) Cloudflare (1.1.1.1, 1.0.0.1)"
    echo "2) Quad9      (9.9.9.9, 149.112.112.112)"
    echo "3) Google     (8.8.8.8, 8.8.4.4)"
    echo "4) Automático (ISP - DHCP)"
    echo "5) Salir"
    read -p " Selecciona una opción: " dns_choice

    local target_ips=""
    local provider_name=""

    case "$dns_choice" in
        1) target_ips="1.1.1.1 1.0.0.1"; provider_name="Cloudflare" ;;
        2) target_ips="9.9.9.9 149.112.112.112"; provider_name="Quad9" ;;
        3) target_ips="8.8.8.8 8.8.4.4"; provider_name="Google" ;;
        4) target_ips="auto"; provider_name="ISP (Auto)" ;;
        *) return 0 ;;
    esac

    # 1. Asegurar compatibilidad de resolv.conf en Arch Linux
    # Esto vincula el archivo que maneja NM con el sistema
    if [[ ! -L "/etc/resolv.conf" ]]; then
        sudo rm -f /etc/resolv.conf
        sudo ln -sf /run/NetworkManager/resolv.conf /etc/resolv.conf
        echo "[+] Enlace simbólico resolv.conf creado."
    fi

    # 2. Guardar preferencia para el Dispatcher
    echo "$target_ips" | sudo tee /etc/NetworkManager/dns-preference > /dev/null

    # 3. Crear el Dispatcher Script para automatizar redes nuevas/Hotspots
    sudo tee /etc/NetworkManager/dispatcher.d/99-dns-exclusive > /dev/null << 'EOF'
#!/bin/bash
# Script de persistencia DNS para evitar multiplexing
interface=$1
status=$2
DNS_PREF="/etc/NetworkManager/dns-preference"

if [ "$status" = "up" ] && [ -f "$DNS_PREF" ]; then
    # Pequeña espera para asegurar que el DHCP ya entregó sus datos
    sleep 2
    TARGET=$(cat "$DNS_PREF")
    
    if [ "$TARGET" != "auto" ]; then
        # Obtener el UUID de la conexión activa en la interfaz actual
        UUID=$(nmcli -t -f uuid,device connection show --active | grep "$interface" | cut -d: -f1)
        
        if [ -n "$UUID" ]; then
            # Configurar prioridad máxima y omitir DNS del ISP
            nmcli connection modify "$UUID" \
                ipv4.ignore-auto-dns yes \
                ipv4.dns "$TARGET" \
                ipv4.dns-priority -1
            
            # Re-aplicar cambios sin reiniciar la conexión (evita bucles infinitos)
            nmcli device reapply "$interface" > /dev/null 2>&1
        fi
    fi
fi
EOF

    # 4. Asignar permisos de ejecución al script
    sudo chmod +x /etc/NetworkManager/dispatcher.d/99-dns-exclusive

    # 5. Aplicar inmediatamente a la conexión actual
    local active_conn
    active_conn=$(nmcli -t -f NAME connection show --active | head -n1)

    if [[ -n "$active_conn" ]]; then
        echo "[*] Aplicando $provider_name a la conexión activa: $active_conn"
        if [[ "$target_ips" == "auto" ]]; then
            sudo nmcli connection modify "$active_conn" ipv4.ignore-auto-dns no ipv4.dns "" ipv4.dns-priority 0
        else
            sudo nmcli connection modify "$active_conn" ipv4.ignore-auto-dns yes ipv4.dns "$target_ips" ipv4.dns-priority -1
        fi
        
        # Activar cambios inmediatamente
        sudo nmcli connection up "$active_conn" > /dev/null 2>&1
    fi

    echo "✅ Éxito: DNS configurado como $provider_name."
    echo "ℹ️ El Dispatcher Script se encargará de mantener esta configuración en cualquier red nueva."
}

setup_firewall() {
    local TITLE="🛡️ CONFIGURACIÓN DE FIREWALL (UFW)"
    
    # 🔍 DETECCIÓN AUTOMÁTICA
    if command -v ufw >/dev/null 2>&1 && sudo ufw status | grep -q "Status: active"; then
        log_ok "UFW ✅ YA ACTIVO (saltando configuración)"
        
        # Verificar reglas SSH
        if sudo ufw status | grep -q "22.*ALLOW"; then
            log_ok "SSH ✅ YA PERMITIDO (Puerto 22 ALLOW)"
        else
            log_msg "SSH ❌ CERRADO actualmente"
        fi
        return 0
    fi
    
    echo "$TITLE"
    echo -e "\nUFW no detectado/activo. ¿Instalar y configurar ahora? (y/N)"
    read -r -p " > " ufw_choice
    
    if [[ ! "$ufw_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log_msg "Saltando configuración de Firewall."
        return 0
    fi
    
    echo "Instalando paquetes UFW..."
    sudo pacman -S --needed --noconfirm ufw gufw
    
    sudo ufw --force reset >/dev/null
    
    echo "Aplicando políticas por defecto (Deny Incoming / Allow Outgoing)..."
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    
    echo -e "\n¿Deseas permitir conexiones SSH entrantes (Puerto 22)? (y/N)"
    echo "   (Útil si administras esta PC desde otro dispositivo)"
    read -r -p " > " ssh_choice
    
    if [[ "$ssh_choice" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        sudo ufw allow ssh
        log_ok "Regla SSH (Puerto 22) agregada."
    else
        log_ok "SSH mantenido cerrado."
    fi
    
    echo "y" | sudo ufw enable
    sudo systemctl enable --now ufw
    
    if sudo ufw status | grep -q "Status: active"; then
        log_ok "✅ Firewall configurado y ACTIVO."
        echo -e "\nEstado actual:"
        sudo ufw status verbose
    else
        log_err "❌ Hubo un problema activando UFW."
    fi
}


# ==================== FLUJO PRINCIPAL ====================
main() {

    # Forzar credenciales sudo una vez
    if sudo -v; then
        log_ok "Sesion sudo cacheada ✅"
    else
        log_err "No se pudo obtener sudo"
        exit 1
    fi
    
    log_msg "Kernel: $(uname -r) | Headers: $KERNEL_HEADERS"

    setup_firewall
    setup_dns
    
    read -r -p "¿VMs (VirtualBox/VMware)? [y/N] " choice
    case "$choice" in [Yy]*) 
        install_virtualbox
        install_vmware
    ;; *)
        log_msg "Saltando VMs"
    esac
    
    read -r -p "¿Burp/Caido? [y/N] " choice
    case "$choice" in [Yy]*) 
        install_burp
        install_caido
    ;; *)
        log_msg "Saltando Burp/Caido"
    esac
    
    setup_firejail_browsers

    log_ok "¡LISTO! Reinicia sesión → burp, caido, virtualbox, vmware"
}

main "$@"
