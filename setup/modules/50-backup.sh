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
