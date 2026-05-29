cleanup_temp_repo() {
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
}
