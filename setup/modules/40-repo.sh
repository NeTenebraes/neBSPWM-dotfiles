repo_default_branch() {
    local repo="$1"
    local branch
    branch=$(git -C "$repo" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||')
    if [[ -z "$branch" ]]; then
        for candidate in main master; do
            if git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$candidate"; then
                branch="$candidate"
                break
            fi
        done
    fi
    echo "$branch"
}

normalize_repo_slug() {
    local url="$1"
    echo "$url" | sed -E 's#(git@github.com:|https://github.com/)([^/]+/[^/.]+)(\.git)?#\2#'
}

is_dotfiles_repo() {
    local repo_root="$1"
    local remote_url
    remote_url=$(git -C "$repo_root" remote get-url origin 2>/dev/null || echo "")
    local repo_slug
    repo_slug=$(normalize_repo_slug "$remote_url" | tr '[:upper:]' '[:lower:]')

    if [[ "$repo_slug" == "netenebraes/nebspwm-dotfiles" || "$repo_slug" == "netenebraes/nebspwn-dotfiles" ]]; then
        return 0
    fi

    [[ -f "$repo_root/setup.sh" && -d "$repo_root/Config Files" && -d "$repo_root/Home files" ]]
}

update_repo_if_needed() {
    local repo="$1"

    if ! git -C "$repo" rev-parse --is-inside-work-tree &>/dev/null; then
        return 1
    fi

    if ! git -C "$repo" diff --quiet || ! git -C "$repo" diff --cached --quiet; then
        echo_skip "Repo con cambios locales; se omite actualización automática."
        return 0
    fi

    git -C "$repo" fetch --quiet origin

    local branch
    branch=$(repo_default_branch "$repo")
    if [[ -z "$branch" ]]; then
        echo_skip "No se pudo detectar la rama principal; se omite actualización."
        return 0
    fi

    local behind
    behind=$(git -C "$repo" rev-list --count "HEAD..origin/$branch" 2>/dev/null || echo "0")
    if [[ "$behind" -gt 0 ]]; then
        echo_msg "🔄 Repo desactualizado ($behind commits). Actualizando..."
        git -C "$repo" pull --ff-only
        echo_ok "Repo actualizado."
    else
        echo_ok "Repo ya está actualizado."
    fi
}

ensure_repo() {
    # 7. GESTIÓN INTELIGENTE DEL REPO
    echo_msg "📥 GESTIONANDO REPO DOTFILES..."
    local tmp_repo="/tmp/neBSPWN-dotfiles"
    local setup_root="${SETUP_ROOT:-}"

    if [[ -z "$setup_root" ]]; then
        local module_dir
        module_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
        setup_root=$(cd "$module_dir/../.." && pwd)
    fi

    # 1) Si el repo está en la carpeta actual o donde vive el setup, usarlo y actualizar si hace falta
    local candidates=()
    candidates+=("$(pwd)")
    [[ -n "$setup_root" ]] && candidates+=("$setup_root")

    for candidate in "${candidates[@]}"; do
        if git -C "$candidate" rev-parse --is-inside-work-tree &>/dev/null; then
            local repo_root
            repo_root=$(git -C "$candidate" rev-parse --show-toplevel)
            if is_dotfiles_repo "$repo_root"; then
                echo -e "\n✨ DETECTADO: Repo local: $repo_root"
                update_repo_if_needed "$repo_root"
                export NE_TMP_REPO="$repo_root"
                echo_ok "Ruta de trabajo establecida en: $NE_TMP_REPO"
                echo_ok "Fuentes + Repo OK"
                return 0
            fi
        fi
    done

    # 2) Si no está en la carpeta actual, usar /tmp (clonar o actualizar si corresponde)
    if [[ -d "$tmp_repo/.git" ]]; then
        if ! is_dotfiles_repo "$tmp_repo"; then
            echo_skip "Repo temporal no coincide; re-clonando..."
            rm -rf "$tmp_repo"
        fi
    elif [[ -d "$tmp_repo" ]]; then
        echo_skip "Directorio temporal existe pero no es un repo; limpiando..."
        rm -rf "$tmp_repo"
    fi

    if [[ -d "$tmp_repo/.git" ]]; then
        update_repo_if_needed "$tmp_repo"
    else
        echo_msg "📥 Clonando repo en temporal..."
        git clone "$DOTFILES_REPO" "$tmp_repo"
    fi

    export NE_TMP_REPO="$tmp_repo"
    echo_ok "Ruta de trabajo establecida en: $NE_TMP_REPO"
    echo_ok "Fuentes + Repo OK"
}
