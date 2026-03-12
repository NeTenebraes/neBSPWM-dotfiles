# Historial básico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE

# Plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh

# --- SINTONIZACIÓN FINA DE COLORES (Tenebrae Minimal) ---
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[root]='none'
ZSH_HIGHLIGHT_STYLES[comment]='fg=#6E6E6E,italic'

# Colores Principales (El "blanco que no es blanco")
ZSH_HIGHLIGHT_STYLES[command]='fg=#e0e0e0,bold'          
ZSH_HIGHLIGHT_STYLES[alias]='fg=#e0e0e0,bold'            
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#e0e0e0'               
ZSH_HIGHLIGHT_STYLES[function]='fg=#e0e0e0'              

# Errores y Alertas (Rojo Neón de Starship)
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff4d4d,bold'    

# Elementos secundarios (Gris Platino para minimalismo)
ZSH_HIGHLIGHT_STYLES[path]='fg=#a9b1d6'                  
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#a9b1d6'
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#a9b1d6'              
ZSH_HIGHLIGHT_STYLES[operator]='fg=#a9b1d6'              
ZSH_HIGHLIGHT_STYLES[separator]='fg=#a9b1d6'             
ZSH_HIGHLIGHT_STYLES[bracket]='fg=#a9b1d6'               

# Cadenas de texto y argumentos
ZSH_HIGHLIGHT_STYLES[string]='fg=#f0f0f0'                
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#a9b1d6'  
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#a9b1d6'
# Completado PRO
autoload -U compinit
compinit
zstyle ':completion:*' menu select list-colors ''
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
setopt COMPLETE_ALIASES

# FZF + ZSH
export TERM=xterm-256color
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# =================================================================
# SHORTCUTS DE TECLADO (FIX Ctrl+Espacio)
# =================================================================
TRAPWINCH() { zle && zle reset-prompt }

# FIX SUPR + BACKSPACE
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# NAVEGACIÓN WORD
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
bindkey '^Y' yank                    # Ctrl+Y
bindkey '\ed' kill-word              # Alt+D

# HISTORIAL
bindkey '^R' history-incremental-search-backward  # Ctrl+R
bindkey '^S' history-incremental-search-forward   # Ctrl+S
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# SELECCIÓN + MARK
bindkey '^X^X' exchange-point-and-mark             # Ctrl+X Ctrl+X
bindkey '^G' cancel                                # Ctrl+G

# PANTALLA
bindkey '^L' clear-screen                          # Ctrl+L

# FZF (SIN Ctrl+Espacio)
bindkey '^T' fzf-file-widget                       # Ctrl+T archivos
bindkey '^G^F' fzf-history-widget                  # Ctrl+G Ctrl+F historial  
bindkey '^[e' fzf-cd-widget                        # Alt+E directorios

# STARSHIP
eval "$(starship init zsh)"

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

# Presiona ESC dos veces para añadir sudo al principio de la línea
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