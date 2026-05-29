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

main "$@"
