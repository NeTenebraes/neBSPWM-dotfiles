# =================================================================
# 0. PATHS 
# # =================================================================
export GOROOT=/usr/lib/go
export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
export PATH="$HOME/.local/bin:$PATH"
# =================================================================
# 1. ENTORNO Y RUTAS (ENVIRONMENT)
# =================================================================
[[ -d "$HOME/.fzf/bin" ]] && export PATH="$PATH:$HOME/.fzf/bin"

# Carga la integración de fzf directamente sin archivos externos
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
fi

export TERM=xterm-256color
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# =================================================================
# 2. HISTORIAL
# =================================================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY          # Compartir historial entre terminales
setopt HIST_IGNORE_DUPS       # No registrar duplicados seguidos
setopt HIST_IGNORE_SPACE      # No registrar comandos que empiecen con espacio

# =================================================================
# 3. COMPLETADO Y SISTEMA (COMPINIT)
# =================================================================
autoload -U compinit && compinit
zstyle ':completion:*' menu select list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
setopt COMPLETE_ALIASES

# =================================================================
# 4. PLUGINS (Carga externa)
# =================================================================
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# =================================================================
# 5. APARIENCIA (Tenebrae Minimal)
# =================================================================
# SINTONIZACIÓN FINA DE COLORES
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[root]='none'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6E6E6E,italic'

# Colores Principales (Blanco suave)
ZSH_HIGHLIGHT_STYLES[command]='fg=#e0e0e0,bold'          
ZSH_HIGHLIGHT_STYLES[alias]='fg=#e0e0e0,bold'            
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#e0e0e0'               
ZSH_HIGHLIGHT_STYLES[function]='fg=#e0e0e0'              

# Errores y Alertas
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff4d4d,bold'    

# Elementos secundarios (Gris Platino)
ZSH_HIGHLIGHT_STYLES[path]='fg=#a9b1d6'                  
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#a9b1d6'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#a9b1d6'              
ZSH_HIGHLIGHT_STYLES[operator]='fg=#a9b1d6'              
ZSH_HIGHLIGHT_STYLES[separator]='fg=#a9b1d6'             
ZSH_HIGHLIGHT_STYLES[bracket]='fg=#a9b1d6'               

# Cadenas de texto y opciones
ZSH_HIGHLIGHT_STYLES[string]='fg=#f0f0f0'                
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#a9b1d6'  
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#a9b1d6'

# STARSHIP PROMPT
eval "$(starship init zsh)"

# =================================================================
# 6. SHORTCUTS DE TECLADO (KEYBINDINGS)
# =================================================================
TRAPWINCH() { zle && zle reset-prompt }

# FIX SUPR + BACKSPACE + NAVEGACIÓN WORD
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word      # Ctrl+←
bindkey '^[[5D'   backward-word      # Option+←  
bindkey '^[[1;5C' forward-word       # Ctrl+→
bindkey '^[[5C'   forward-word       # Option+→

# BÁSICOS EMACS
bindkey '^A' beginning-of-line       # Ctrl+A
bindkey '^E' end-of-line             # Ctrl+E
bindkey '^K' kill-line               # Ctrl+K
bindkey '^U' backward-kill-line      # Ctrl+U
bindkey '^W' backward-kill-word      # Ctrl+W
bindkey '\ed' kill-word              # Alt+D

# HISTORIAL & SUBSTRING SEARCH
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# FZF WIDGETS
bindkey '^T' fzf-file-widget          # Ctrl+T archivos
bindkey '^G^F' fzf-history-widget     # Ctrl+G+F historial  
bindkey '^[e' fzf-cd-widget           # Alt+E directorios

# OTROS
bindkey '^X^X' exchange-point-and-mark
bindkey '^G' cancel
bindkey '^L' clear-screen

# =================================================================
# 7. FUNCIONES Y ALIAS CUSTOM
# =================================================================

# ESC ESC para añadir SUDO
sudo-command-line() {
    [[ -z $BUFFER ]] && zle up-history
    if [[ $BUFFER == sudo\ * ]]; then
        LBUFFER="${LBUFFER#sudo }"
    else
        LBUFFER="sudo $LBUFFER"
    fi
}
zle -N sudo-command-line
bindkey "\e\e" sudo-command-line

# ALIAS: Modo Video / Laboratorio
alias modo-video='
    export VIDEO_HOME=$(mktemp -d /tmp/video-LABS-XXXXXX)
    export HOME=$VIDEO_HOME
    cd $HOME

    PROMPT="%F{#6E6E6E}┌─%f %F{#89dceb}%n%f%F{white}@LABS%f in %F{#a9b1d6}󰉋 %f%F{white}%1~%f
%F{#6E6E6E}└─%f%F{#a9b1d6}>>%f "

    unset RPROMPT
    precmd_functions=() 

    clear
    echo "── LABS VIRTUAL ENVIRONMENT ACTIVE ──"
    echo "HOME: $HOME"
'
