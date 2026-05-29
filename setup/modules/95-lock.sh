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
