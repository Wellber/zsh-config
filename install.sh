#!/bin/bash
# ======================================================================
# Script de Instalação ZSH + Oh My Zsh - Wellber Santos
# Versão: 1.1
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
    if ! command -v zsh &> /dev/null || ! command -v git &> /dev/null || ! command -v curl &> /dev/null || ! command -v wget &> /dev/null; then
        log_info "Atualizando repositórios..."
        eval "$PKG_UPDATE" 2>/dev/null

        log_info "Instalando dependências (zsh, git, curl, wget)..."
        eval "$PKG_INSTALL zsh git curl wget" 2>/dev/null
        log_success "Dependências instaladas!"
    else
        log_warn "Dependências já instaladas. Pulando..."
    fi
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

# Configura o .zshrc
configure_zshrc() {
    log_info "Configurando .zshrc..."

    # Backup do .zshrc atual
    if [ -f "$HOME/.zshrc" ]; then
        if ! cmp -s "$HOME/.zshrc" "$HOME/.zshrc.backup.*" 2>/dev/null; then
            cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
            log_info "Backup criado: ~/.zshrc.backup.*"
        else
            log_warn "O arquivo .zshrc já possui backup idêntico. Pulando backup."
        fi
    fi

    # Obtém o diretório do script
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # Copia o .zshrc configurado
    if [ -f "$SCRIPT_DIR/.zshrc" ]; then
        cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
        log_success ".zshrc configurado a partir do repositório!"
    else
        # Se executado via curl, baixa o .zshrc
        log_info "Baixando .zshrc do repositório..."
        if curl -fsSL https://raw.githubusercontent.com/Wellber/zsh-config/main/.zshrc -o "$HOME/.zshrc" 2>/dev/null; then
            log_success ".zshrc baixado com sucesso!"
        else
            log_warn "Não foi possível baixar .zshrc. Usando configuração padrão do Oh My Zsh."
        fi
    fi
}
install_chsh() {
    if ! command -v chsh &> /dev/null; then
        log_info "chsh não encontrado. Instalando util-linux..."
        eval "$PKG_INSTALL util-linux" 2>/dev/null
        if command -v chsh &> /dev/null; then
            log_success "chsh instalado com sucesso!"
        else
            log_error "Falha ao instalar chsh. Verifique manualmente."
        fi
    else
        log_warn "chsh já está instalado. Pulando..."
    fi
}
# Define ZSH como shell padrão
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "Definindo ZSH como shell padrão..."
        if chsh -s "$(which zsh)" 2>/dev/null; then
            log_success "ZSH definido como shell padrão!"
        else
            log_warn "Não foi possível alterar o shell automaticamente."
            log_warn "Execute manualmente: chsh -s \$(which zsh)"
        fi
    else
        log_info "ZSH já é o shell padrão."
    fi
}

# Instala fontes recomendadas (opcional)
install_fonts() {
    log_info "Deseja instalar as fontes Nerd Fonts (recomendado para Powerlevel10k)? [s/N]"
    read -r response
    if [[ "$response" =~ ^[Ss]$ ]]; then
        FONT_DIR="$HOME/.local/share/fonts"
        mkdir -p "$FONT_DIR"

        FONTS=(
            "MesloLGS%20NF%20Regular.ttf"
            "MesloLGS%20NF%20Bold.ttf"
            "MesloLGS%20NF%20Italic.ttf"
            "MesloLGS%20NF%20Bold%20Italic.ttf"
        )

        # Verifica se as fontes já estão instaladas
        if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
            log_info "Instalando fontes MesloLGS NF..."
            for font in "${FONTS[@]}"; do
                curl -fsSL "https://github.com/romkatv/powerlevel10k-media/raw/master/$font" -o "$FONT_DIR/${font//%20/ }" 2>/dev/null
            done

            # Atualiza cache de fontes
            if command -v fc-cache &> /dev/null; then
                fc-cache -f "$FONT_DIR"
            fi
            log_success "Fontes instaladas! Configure seu terminal para usar 'MesloLGS NF'."
        else
            log_warn "Fontes Nerd Fonts já instaladas. Pulando..."
        fi
    fi
}

# Função principal
main() {
    echo ""
    echo "======================================================================"
    echo "   Instalador ZSH + Oh My Zsh + Powerlevel10k"
    echo "   Por: Wellber Santos"
    echo "======================================================================"
    echo ""

    # Verifica se está rodando como root
    if [ "$EUID" -eq 0 ]; then
        log_warn "Executando como root. Recomendado executar como usuário normal. Deseja continuar? [s/N]"
        read -r response
        if ! [[ "$response" =~ ^[Ss]$ ]]; then
            log_error "Instalação cancelada."
            exit 1
        fi
    fi

    detect_package_manager
    install_chsh
    install_dependencies
    install_oh_my_zsh
    install_powerlevel10k
    install_plugins
    configure_zshrc
    set_default_shell

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
    log_info "Na primeira execução, o Powerlevel10k irá iniciar o assistente de configuração automaticamente."
    echo ""
}

# Executa
main "$@"

