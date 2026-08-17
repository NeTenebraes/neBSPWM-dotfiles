#TODO: Refactorizar

setup_sddm() {
    echo_msg "Iniciando módulo SDDM..."

    # Variables Locales
    local THEME_DEST_NAME="netenebrae"
    local THEMES_DIR="/usr/share/sddm/themes"
    local TARGET_DIR="$THEMES_DIR/$THEME_DEST_NAME"
    local METADATA="$TARGET_DIR/metadata.desktop"
    local CLONE_DIR="${NE_TMP_REPO:-/tmp/neBSPWN-dotfiles}"
    local DATE
    DATE=$(date +%s)

    # Localizar archivos SDDM en el repo
    local source_path=""

    if [[ -f "$CLONE_DIR/configuracion-del-sistema/SDDM/metadata.desktop" ]]; then
        source_path="$CLONE_DIR/configuracion-del-sistema/SDDM"
    elif [[ -f "$CLONE_DIR/SDDM/metadata.desktop" ]]; then
        source_path="$CLONE_DIR/SDDM"
    else
        local found
        found=$(find "$CLONE_DIR" -type f -name "metadata.desktop" | grep "SDDM" | head -n 1)
        if [[ -n "$found" ]]; then
            source_path=$(dirname "$found")
        else
            echo_err "No se encontró la carpeta del tema SDDM en $CLONE_DIR"
            return 1
        fi
    fi

    echo_ok "Fuente encontrada: $source_path"

    # 3. Instalación Limpia
    if [[ -d "$TARGET_DIR" ]]; then
        echo_msg "Removiendo tema anterior..."
        sudo rm -fr "$TARGET_DIR"
    fi

    sudo mkdir -p "$TARGET_DIR"
    echo_msg "Copiando archivos a $TARGET_DIR..."
    sudo cp -r "$source_path"/* "$TARGET_DIR"/

    # Fuentes
    if [[ -d "$TARGET_DIR/Fonts" ]]; then
        echo_msg "Instalando fuentes..."
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
        echo_err "Error crítico: metadata.desktop no encontrado tras copia."
        return 1
    fi

    echo_msg "Configurando Tema"
    # Forzamos la configuración
    sudo sed -i "s|^ConfigFile=.*|ConfigFile=Themes/netenebrae.conf|" "$METADATA"

    # 5. Parche QML de compatibilidad
    local qml_file="$TARGET_DIR/Main.qml"
    if [[ -f "$qml_file" ]]; then
        # Solo aplicamos si detectamos que faltan versiones
        if ! grep -q "QtQuick 2.15" "$qml_file"; then
             echo_msg "💉 Parcheando imports QML..."
             sudo sed -i 's/^import QtQuick$/import QtQuick 2.15/' "$qml_file"
             sudo sed -i 's/^import QtQuick.Layouts$/import QtQuick.Layouts 1.15/' "$qml_file"
             sudo sed -i 's/^import QtQuick.Controls$/import QtQuick.Controls 2.15/' "$qml_file"
        fi
    fi

    # 6. Habilitar Servicio
    if ! systemctl is-enabled sddm &>/dev/null; then
        echo_msg "Habilitando servicio SDDM..."
        sudo systemctl enable sddm
    fi

    echo_ok "SDDM Listo"
}
