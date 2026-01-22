# Historial básico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE
# source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242'

source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
# Esto detecta los códigos de escape de Kitty/Xterm para las flechas

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

alias modo-video="mkdir -p /tmp/video_home && export HOME=/tmp/video_home && cd ~ && source /home/netenebrae/.zshrc && PROMPT='%B%F{red}%n%f%b%F{white}@%f%B%F{red}hacking-lab%f%b:%F{white}%1~%f ➜ ' && clear && echo 'MODO VIDEO: Usuario netenebrae activo en entorno seguro. 💀'"
