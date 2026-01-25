#!/bin/bash
# ======================================================================
# Script de Instalação ZSH + Oh My Zsh - Wellber Santos
# Versão: 2.0
# Uso: curl -fsSL <url>/install.sh | bash
#      ou: ./install.sh
# ======================================================================

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções de log
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Detecta o gerenciador de pacotes
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        PKG_UPDATE="sudo apt-get update -qq"
        PKG_INSTALL="sudo apt-get install -y -qq"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_UPDATE="sudo dnf check-update || true"
        PKG_INSTALL="sudo dnf install -y -q"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_UPDATE="sudo yum check-update || true"
        PKG_INSTALL="sudo yum install -y -q"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        PKG_UPDATE="sudo pacman -Sy --noconfirm"
        PKG_INSTALL="sudo pacman -S --noconfirm"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        PKG_UPDATE="sudo zypper refresh -q"
        PKG_INSTALL="sudo zypper install -y -q"
    else
        log_error "Gerenciador de pacotes não suportado!"
        exit 1
    fi
    log_info "Gerenciador de pacotes detectado: $PKG_MANAGER"
}

# Instala dependências
install_dependencies() {
    log_info "Atualizando repositórios..."
    eval "$PKG_UPDATE" 2>/dev/null

    log_info "Instalando dependências (zsh, git, curl, wget)..."
    eval "$PKG_INSTALL zsh git curl wget" 2>/dev/null
    log_success "Dependências instaladas!"
}

# Instala Oh My Zsh
install_oh_my_zsh() {
    if [ -d "$HOME/.oh-my-zsh" ]; then
        log_warn "Oh My Zsh já está instalado. Pulando..."
    else
        log_info "Instalando Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh instalado!"
    fi
}

# Instala Powerlevel10k
install_powerlevel10k() {
    P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    if [ -d "$P10K_DIR" ]; then
        log_warn "Powerlevel10k já está instalado. Atualizando..."
        git -C "$P10K_DIR" pull -q
    else
        log_info "Instalando tema Powerlevel10k..."
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" 2>/dev/null
    fi
    log_success "Powerlevel10k instalado!"
}

# Instala plugins extras
install_plugins() {
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-autosuggestions
    PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    if [ -d "$PLUGIN_DIR" ]; then
        log_warn "zsh-autosuggestions já instalado. Atualizando..."
        git -C "$PLUGIN_DIR" pull -q 2>/dev/null
    else
        log_info "Instalando plugin zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_DIR" 2>/dev/null
    fi

    # zsh-syntax-highlighting
    PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    if [ -d "$PLUGIN_DIR" ]; then
        log_warn "zsh-syntax-highlighting já instalado. Atualizando..."
        git -C "$PLUGIN_DIR" pull -q 2>/dev/null
    else
        log_info "Instalando plugin zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$PLUGIN_DIR" 2>/dev/null
    fi

    # history-substring-search
    PLUGIN_DIR="$ZSH_CUSTOM/plugins/zsh-history-substring-search"
    if [ -d "$PLUGIN_DIR" ]; then
        log_warn "zsh-history-substring-search já instalado. Atualizando..."
        git -C "$PLUGIN_DIR" pull -q 2>/dev/null
    else
        log_info "Instalando plugin zsh-history-substring-search..."
        git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search "$PLUGIN_DIR" 2>/dev/null
    fi

    log_success "Plugins instalados!"
}

# Configura o .zshrc - sempre baixa do GitHub
configure_zshrc() {
    log_info "Configurando .zshrc..."

    # Backup do .zshrc atual
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
        log_info "Backup criado: ~/.zshrc.backup.*"
    fi

    # Sempre baixa do GitHub para garantir versão mais recente
    log_info "Baixando .zshrc do GitHub..."
    if curl -fsSL https://raw.githubusercontent.com/Wellber/zsh-config/main/.zshrc -o "$HOME/.zshrc" 2>/dev/null; then
        log_success ".zshrc baixado e configurado!"
    else
        # Fallback: tenta usar arquivo local se existir
        SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        if [ -f "$SCRIPT_DIR/.zshrc" ]; then
            cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
            log_success ".zshrc configurado a partir do repositório local!"
        else
            log_warn "Não foi possível baixar .zshrc. Usando configuração padrão do Oh My Zsh."
        fi
    fi
}

# Define ZSH como shell padrão
set_default_shell() {
    ZSH_PATH="$(which zsh)"
    CURRENT_USER="$(whoami)"

    if [ "$SHELL" = "$ZSH_PATH" ]; then
        log_info "ZSH já é o shell padrão."
        return 0
    fi

    log_info "Definindo ZSH como shell padrão..."

    # Verifica se zsh está em /etc/shells
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        log_info "Adicionando ZSH ao /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    # Método 1: Tenta usar chsh
    if command -v chsh &> /dev/null; then
        log_info "Tentando alterar shell via chsh..."
        if chsh -s "$ZSH_PATH" 2>/dev/null; then
            log_success "ZSH definido como shell padrão via chsh!"
            return 0
        fi
        log_warn "chsh falhou, tentando método alternativo..."
    fi

    # Método 2: Tenta instalar chsh via util-linux
    if ! command -v chsh &> /dev/null; then
        log_info "chsh não encontrado. Tentando instalar..."
        case "$PKG_MANAGER" in
            apt-get)
                sudo apt-get install -y -qq passwd 2>/dev/null || true
                ;;
            dnf|yum)
                sudo $PKG_MANAGER install -y -q util-linux-user 2>/dev/null || true
                ;;
            pacman)
                sudo pacman -S --noconfirm shadow 2>/dev/null || true
                ;;
            zypper)
                sudo zypper install -y -q shadow 2>/dev/null || true
                ;;
        esac

        # Tenta novamente com chsh
        if command -v chsh &> /dev/null; then
            if chsh -s "$ZSH_PATH" 2>/dev/null; then
                log_success "ZSH definido como shell padrão via chsh!"
                return 0
            fi
        fi
    fi

    # Método 3: Altera diretamente no /etc/passwd (fallback)
    log_warn "Alterando shell diretamente no /etc/passwd..."
    if sudo sed -i "s|^\($CURRENT_USER:.*:\)[^:]*$|\1$ZSH_PATH|" /etc/passwd 2>/dev/null; then
        # Verifica se a alteração foi feita
        if grep -q "^$CURRENT_USER:.*:$ZSH_PATH$" /etc/passwd; then
            log_success "ZSH definido como shell padrão via /etc/passwd!"
            return 0
        fi
    fi

    # Método 4: Usa usermod como última tentativa
    log_warn "Tentando via usermod..."
    if sudo usermod -s "$ZSH_PATH" "$CURRENT_USER" 2>/dev/null; then
        log_success "ZSH definido como shell padrão via usermod!"
        return 0
    fi

    log_error "Não foi possível alterar o shell automaticamente."
    log_warn "Execute manualmente: sudo usermod -s $ZSH_PATH $CURRENT_USER"
    return 1
}

# Instala e configura MOTD
install_motd() {
    log_info "Configurando MOTD (Message of the Day)..."

    # Cria script MOTD
    MOTD_SCRIPT="/etc/profile.d/motd-info.sh"

    sudo tee "$MOTD_SCRIPT" > /dev/null << 'MOTD_EOF'
#!/bin/bash
# ======================================================================
# MOTD - System Information - Wellber Santos
# ======================================================================

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Coleta informações
HOSTNAME=$(hostname -f 2>/dev/null || hostname)
KERNEL=$(uname -r)
UPTIME=$(uptime -p 2>/dev/null || uptime | sed 's/.*up/up/')
LOAD_AVG=$(cat /proc/loadavg | awk '{print $1", "$2", "$3}')

# CPU Utilization
CPU_UTIL=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' 2>/dev/null || echo "N/A")
if [ "$CPU_UTIL" = "N/A" ]; then
    CPU_UTIL=$(vmstat 1 2 | tail -1 | awk '{print 100-$15}' 2>/dev/null || echo "N/A")
fi

# Memory
MEM_TOTAL=$(free -h | awk '/^Mem:/{print $2}')
MEM_USED=$(free -h | awk '/^Mem:/{print $3}')
MEM_PERCENT=$(free | awk '/^Mem:/{printf "%.1f", $3/$2 * 100}')

# IPs do servidor
IPS=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | tr '\n' ' ')
if [ -z "$IPS" ]; then
    IPS=$(hostname -I 2>/dev/null || echo "N/A")
fi

# Usuários logados
LOGGED_USERS=$(who | wc -l)
USERS_LIST=$(who | awk '{print $1}' | sort -u | tr '\n' ', ' | sed 's/,$//')

# Distro
if [ -f /etc/os-release ]; then
    DISTRO=$(grep "PRETTY_NAME" /etc/os-release | cut -d'"' -f2)
else
    DISTRO=$(uname -o)
fi

# Exibe MOTD
echo ""
echo -e "${CYAN}======================================================================${NC}"
echo -e "${WHITE}                    SYSTEM INFORMATION                               ${NC}"
echo -e "${CYAN}======================================================================${NC}"
echo ""
echo -e "${GREEN}  Hostname:${NC}       $HOSTNAME"
echo -e "${GREEN}  Distro:${NC}         $DISTRO"
echo -e "${GREEN}  Kernel:${NC}         $KERNEL"
echo -e "${GREEN}  Uptime:${NC}         $UPTIME"
echo ""
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  NETWORK${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${GREEN}  IP Address:${NC}     $IPS"
echo ""
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  RESOURCES${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${GREEN}  CPU Usage:${NC}      ${CPU_UTIL}%"
echo -e "${GREEN}  Load Average:${NC}   $LOAD_AVG"
echo -e "${GREEN}  Memory:${NC}         ${MEM_USED} / ${MEM_TOTAL} (${MEM_PERCENT}%)"
echo ""
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${YELLOW}  USERS${NC}"
echo -e "${CYAN}----------------------------------------------------------------------${NC}"
echo -e "${GREEN}  Logged Users:${NC}   $LOGGED_USERS"
echo -e "${GREEN}  Users:${NC}          $USERS_LIST"
echo ""
echo -e "${CYAN}======================================================================${NC}"
echo ""
MOTD_EOF

    sudo chmod +x "$MOTD_SCRIPT"

    # Desabilita MOTD padrão do sistema se existir
    if [ -f /etc/motd ]; then
        sudo mv /etc/motd /etc/motd.bak 2>/dev/null || true
    fi

    # Desabilita scripts padrão do update-motd se existirem
    if [ -d /etc/update-motd.d ]; then
        sudo chmod -x /etc/update-motd.d/* 2>/dev/null || true
    fi

    log_success "MOTD configurado!"
}

# Instala fontes recomendadas (opcional)
install_fonts() {
    log_info "Deseja instalar as fontes Nerd Fonts (recomendado para Powerlevel10k)? [s/N]"
    read -r response
    if [[ "$response" =~ ^[Ss]$ ]]; then
        log_info "Instalando fontes MesloLGS NF..."
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"

        FONTS=(
            "MesloLGS%20NF%20Regular.ttf"
            "MesloLGS%20NF%20Bold.ttf"
            "MesloLGS%20NF%20Italic.ttf"
            "MesloLGS%20NF%20Bold%20Italic.ttf"
        )

        for font in "${FONTS[@]}"; do
            curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/$font" -o "$FONT_DIR/${font//%20/ }" 2>/dev/null
        done

        # Atualiza cache de fontes
        if command -v fc-cache &> /dev/null; then
            fc-cache -f "$FONT_DIR"
        fi

        log_success "Fontes instaladas! Configure seu terminal para usar 'MesloLGS NF'."
    fi
}

# Função principal
main() {
    echo ""
    echo "======================================================================"
    echo "   Instalador ZSH + Oh My Zsh + Powerlevel10k"
    echo "   Por: Wellber Santos - v2.0"
    echo "======================================================================"
    echo ""

    # Verifica se está rodando como root
    if [ "$EUID" -eq 0 ]; then
        log_warn "Executando como root. Recomendado executar como usuário normal."
    fi

    detect_package_manager
    install_dependencies
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    configure_zshrc
    set_default_shell
    install_motd

    # Pergunta sobre fontes apenas se for interativo
    if [ -t 0 ]; then
        install_fonts
    fi

    echo ""
    echo "======================================================================"
    log_success "Instalação concluída!"
    echo "======================================================================"
    echo ""
    log_info "Para aplicar as configurações, execute:"
    echo "      source ~/.zshrc"
    echo ""
    log_info "Ou faça logout e login novamente."
    echo ""
    log_info "Na primeira execução, o Powerlevel10k irá iniciar o assistente"
    log_info "de configuração automaticamente."
    echo ""
}

# Executa
main "$@"
