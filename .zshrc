# ======================================================================
# ZSH Configuração Padrão - Wellber Santos
# Versão: 1.0
# Objetivo: Padronizar todos os servidores Linux com ZSH + Oh My Zsh
# ======================================================================

# Caminho do Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

# Tema (Powerlevel10k)
ZSH_THEME="powerlevel10k/powerlevel10k"

# Ativa os plugins recomendados
plugins=(
  git
  gitfast
  docker
  kubectl
  aws
  terraform
  systemd
  z
  sudo
  command-not-found
  colored-man-pages
  extract
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
  ssh-agent
)

# Carrega o Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ======================================================================
# 🧠 ALIASES E MELHORIAS
# ======================================================================

# Aliases úteis
alias ll='ls -lh --color=auto'
alias la='ls -lha --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias cls='clear'

# Git aliases rápidos
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'

# Docker
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dclean='docker system prune -af'
alias dimages='docker images'

# Kubernetes
alias k='kubectl'
alias kctx='kubectl config use-context'
alias kns='kubectl config set-context --current --namespace'

# AWS
alias awsls='aws s3 ls'
alias awscp='aws s3 cp'

# Rede / Segurança
alias ports='sudo netstat -tulnp'
alias pingg='ping 8.8.8.8'

# ======================================================================
# ⚙️ CONFIGURAÇÕES EXTRAS
# ======================================================================

# Histórico
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS

# Melhorias de terminal
setopt AUTO_CD
setopt CORRECT
setopt SHARE_HISTORY
setopt EXTENDED_GLOB

# Autossugestões visuais
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Carrega completions de plugins externos (kubectl, docker etc)
autoload -U compinit && compinit

# Carrega Powerlevel10k instantaneamente se existir config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Inicia agente SSH automaticamente
eval "$(ssh-agent -s)" >/dev/null
ssh-add ~/.ssh/id_ed25519 >/dev/null 2>&1

# ======================================================================
# 💡 FIM DA CONFIGURAÇÃO
# ======================================================================

