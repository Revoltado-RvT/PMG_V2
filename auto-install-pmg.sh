#!/bin/bash

################################################################################
# PNETLab Manager v3.0 - Instalador Automatizado
# Instalação completa do zero sem interação do usuário
################################################################################

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Configurações
GITHUB_REPO="https://github.com/Revoltado-RvT/PMG_V2"
TEMP_DIR="/tmp/pmg-install-$$"
INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="pmg"

################################################################################
# Funções de Log
################################################################################

print_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║     ██████╗ ███╗   ██╗███████╗████████╗██╗      █████╗ ██████╗║
║     ██╔══██╗████╗  ██║██╔════╝╚══██╔══╝██║     ██╔══██╗██╔══██╗
║     ██████╔╝██╔██╗ ██║█████╗     ██║   ██║     ███████║██████╔╝
║     ██╔═══╝ ██║╚██╗██║██╔══╝     ██║   ██║     ██╔══██║██╔══██╗
║     ██║     ██║ ╚████║███████╗   ██║   ███████╗██║  ██║██████╔╝
║     ╚═╝     ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═════╝ ║
║                                                               ║
║            Manager v3.0 - Instalador Automático              ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${BLUE}Repositório:${NC} $GITHUB_REPO"
    echo -e "${BLUE}Instalando em:${NC} $INSTALL_DIR"
    echo
}

log_step() {
    echo -e "${CYAN}[$(date +%H:%M:%S)]${NC} $1"
}

log_info() {
    echo -e "${BLUE}  ℹ${NC}  $1"
}

log_success() {
    echo -e "${GREEN}  ✓${NC}  $1"
}

log_warning() {
    echo -e "${YELLOW}  ⚠${NC}  $1"
}

log_error() {
    echo -e "${RED}  ✗${NC}  $1"
}

log_progress() {
    echo -e "${MAGENTA}  →${NC}  $1"
}

################################################################################
# Verificações de Sistema
################################################################################

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "NÃO execute este script como root!"
        log_info "Use: ${CYAN}./auto-install-pmg.sh${NC}"
        exit 1
    fi
    log_success "Executando como usuário normal"
}

check_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        log_info "Sistema detectado: ${CYAN}$PRETTY_NAME${NC}"
        
        # Detectar se é baseado em Debian ou RedHat
        if [[ "$ID_LIKE" == *"debian"* ]] || [[ "$ID" == "ubuntu" ]] || [[ "$ID" == "debian" ]]; then
            PKG_MANAGER="apt-get"
            PKG_UPDATE="sudo apt-get update -qq"
            PKG_INSTALL="sudo apt-get install -y -qq"
        elif [[ "$ID_LIKE" == *"rhel"* ]] || [[ "$ID" == "centos" ]] || [[ "$ID" == "fedora" ]]; then
            PKG_MANAGER="yum"
            PKG_UPDATE="sudo yum check-update -q || true"
            PKG_INSTALL="sudo yum install -y -q"
        else
            log_warning "Distribuição não detectada automaticamente"
            PKG_MANAGER="apt-get"
            PKG_UPDATE="sudo apt-get update -qq"
            PKG_INSTALL="sudo apt-get install -y -qq"
        fi
        
        log_success "Gerenciador de pacotes: ${CYAN}$PKG_MANAGER${NC}"
    fi
}

install_dependencies() {
    log_step "Verificando e instalando dependências..."
    
    local deps_required=("curl" "wget" "unzip" "python3")
    local deps_optional=("qemu-img" "sshpass" "git")
    local missing_required=()
    local missing_optional=()
    
    # Verificar dependências obrigatórias
    for dep in "${deps_required[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log_success "$dep - instalado"
        else
            log_warning "$dep - não encontrado"
            missing_required+=("$dep")
        fi
    done
    
    # Instalar dependências obrigatórias faltantes
    if [ ${#missing_required[@]} -gt 0 ]; then
        log_progress "Instalando dependências obrigatórias..."
        
        # Converter nomes de pacotes
        local packages=()
        for dep in "${missing_required[@]}"; do
            case $dep in
                qemu-img) packages+=("qemu-utils") ;;
                *) packages+=("$dep") ;;
            esac
        done
        
        # Atualizar repositórios
        log_info "Atualizando repositórios..."
        eval "$PKG_UPDATE" 2>/dev/null || log_warning "Falha ao atualizar repositórios"
        
        # Instalar pacotes
        log_info "Instalando: ${packages[*]}"
        if eval "$PKG_INSTALL ${packages[*]}" 2>/dev/null; then
            log_success "Dependências obrigatórias instaladas"
        else
            log_error "Falha ao instalar dependências"
            log_info "Execute manualmente: ${CYAN}$PKG_INSTALL ${packages[*]}${NC}"
            exit 1
        fi
    else
        log_success "Todas as dependências obrigatórias estão instaladas"
    fi
    
    # Verificar dependências opcionais
    echo
    log_info "Dependências opcionais (para funcionalidades extras):"
    for dep in "${deps_optional[@]}"; do
        if command -v "$dep" &>/dev/null; then
            log_success "$dep - instalado"
        else
            log_warning "$dep - não instalado (opcional)"
        fi
    done
    echo
}

################################################################################
# Download e Extração
################################################################################

download_from_github() {
    log_step "Baixando do GitHub..."
    
    # Criar diretório temporário
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # URL do arquivo ZIP
    local zip_url="${GITHUB_REPO}/archive/refs/heads/main.zip"
    
    log_progress "Downloading: $zip_url"
    
    if wget -q --show-progress "$zip_url" -O pmg.zip 2>&1 | grep -o '\([0-9]\+%\|[0-9.]\+[KMG]\)' | tail -1; then
        log_success "Download concluído"
    else
        log_error "Falha no download"
        log_info "Verifique sua conexão e o URL: $zip_url"
        cleanup
        exit 1
    fi
}

extract_files() {
    log_step "Extraindo arquivos..."
    
    cd "$TEMP_DIR"
    
    if unzip -q pmg.zip; then
        log_success "Arquivos extraídos"
    else
        log_error "Falha ao extrair arquivos"
        cleanup
        exit 1
    fi
    
    # Encontrar diretório extraído
    local extracted_dir=$(find . -maxdepth 1 -type d -name "PMG_V2-*" | head -1)
    
    if [ -z "$extracted_dir" ]; then
        log_error "Diretório extraído não encontrado"
        cleanup
        exit 1
    fi
    
    cd "$extracted_dir"
    log_info "Diretório de trabalho: $(pwd)"
}

################################################################################
# Instalação
################################################################################

install_files() {
    log_step "Instalando arquivos..."
    
    # Criar diretório de instalação
    mkdir -p "$INSTALL_DIR"
    log_success "Diretório criado: $INSTALL_DIR"
    
    # Verificar arquivos necessários
    if [[ ! -f "pnetlab-manager-v3.sh" ]]; then
        log_error "Arquivo pnetlab-manager-v3.sh não encontrado!"
        cleanup
        exit 1
    fi
    
    if [[ ! -f "labhub_parser.py" ]]; then
        log_error "Arquivo labhub_parser.py não encontrado!"
        cleanup
        exit 1
    fi
    
    # Copiar script principal
    log_progress "Copiando script principal..."
    cp pnetlab-manager-v3.sh "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    log_success "Script: $INSTALL_DIR/$SCRIPT_NAME"
    
    # Copiar parser Python
    log_progress "Copiando parser Python..."
    cp labhub_parser.py "$INSTALL_DIR/labhub_parser.py"
    chmod +x "$INSTALL_DIR/labhub_parser.py"
    log_success "Parser: $INSTALL_DIR/labhub_parser.py"
    
    # Verificar permissões
    if [[ -x "$INSTALL_DIR/$SCRIPT_NAME" ]] && [[ -x "$INSTALL_DIR/labhub_parser.py" ]]; then
        log_success "Permissões aplicadas corretamente"
    else
        log_warning "Verificando permissões novamente..."
        chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
        chmod +x "$INSTALL_DIR/labhub_parser.py"
    fi
}

configure_shell() {
    log_step "Configurando shell..."
    
    local shell_rc="${HOME}/.bashrc"
    local path_line="export PATH=\"\$PATH:$INSTALL_DIR\""
    local alias_line="alias pmg='$INSTALL_DIR/$SCRIPT_NAME'"
    
    # Adicionar ao PATH se necessário
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        if ! grep -q "$path_line" "$shell_rc" 2>/dev/null; then
            echo >> "$shell_rc"
            echo "# PNETLab Manager v3.0" >> "$shell_rc"
            echo "$path_line" >> "$shell_rc"
            log_success "PATH adicionado ao $shell_rc"
        else
            log_info "PATH já configurado"
        fi
    else
        log_success "Diretório já está no PATH"
    fi
    
    # Adicionar alias se não existir
    if ! grep -q "alias pmg=" "$shell_rc" 2>/dev/null; then
        echo "$alias_line" >> "$shell_rc"
        log_success "Alias 'pmg' criado"
    else
        log_info "Alias já existe"
    fi
    
    # Exportar PATH imediatamente para esta sessão
    export PATH="$PATH:$INSTALL_DIR"
}

apply_pnetlab_permissions() {
    log_step "Aplicando permissões PNETLab/EVE-NG..."
    
    # Verificar se existe o wrapper do UNetLab/EVE-NG
    local wrapper="/opt/unetlab/wrappers/unl_wrapper"
    
    if [[ -f "$wrapper" ]]; then
        log_info "Wrapper encontrado: $wrapper"
        
        if command -v sudo &>/dev/null; then
            log_progress "Executando fixpermissions..."
            
            if sudo "$wrapper" -a fixpermissions 2>/dev/null; then
                log_success "Permissões PNETLab/EVE-NG aplicadas"
            else
                log_warning "Falha ao aplicar permissões (pode não ser necessário neste momento)"
                log_info "Execute manualmente se necessário: ${CYAN}sudo $wrapper -a fixpermissions${NC}"
            fi
        else
            log_warning "sudo não disponível - pule esta etapa se não estiver em servidor PNETLab/EVE-NG"
        fi
    else
        log_info "Sistema não é PNETLab/EVE-NG - pulando fixpermissions"
        log_info "Execute manualmente no servidor se necessário"
    fi
}

################################################################################
# Testes
################################################################################

test_installation() {
    log_step "Testando instalação..."
    
    # Testar se o comando funciona
    if "$INSTALL_DIR/$SCRIPT_NAME" help &>/dev/null; then
        log_success "Comando 'pmg help' funciona"
    else
        log_error "Falha ao executar comando"
        return 1
    fi
    
    # Testar parser Python
    if python3 "$INSTALL_DIR/labhub_parser.py" --help &>/dev/null; then
        log_success "Parser Python funciona"
    else
        log_warning "Parser pode ter problemas - verifique Python 3"
    fi
    
    # Testar conectividade (opcional)
    if "$INSTALL_DIR/$SCRIPT_NAME" test &>/dev/null; then
        log_success "Teste de conectividade passou"
    else
        log_info "Teste de conectividade falhou (normal antes da configuração)"
    fi
}

################################################################################
# Limpeza
################################################################################

cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        log_info "Limpando arquivos temporários..."
        rm -rf "$TEMP_DIR"
        log_success "Limpeza concluída"
    fi
}

################################################################################
# Resumo Final
################################################################################

print_summary() {
    echo
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║              ✓ INSTALAÇÃO CONCLUÍDA COM SUCESSO!             ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    echo -e "${CYAN}📁 Localização dos Arquivos:${NC}"
    echo -e "   ${BLUE}→${NC} Script principal: ${GREEN}$INSTALL_DIR/$SCRIPT_NAME${NC}"
    echo -e "   ${BLUE}→${NC} Parser Python:    ${GREEN}$INSTALL_DIR/labhub_parser.py${NC}"
    echo
    
    echo -e "${CYAN}🚀 Próximos Passos:${NC}"
    echo
    echo -e "   ${YELLOW}1.${NC} Recarregue seu shell:"
    echo -e "      ${GREEN}source ~/.bashrc${NC}"
    echo -e "      ${BLUE}ou abra um novo terminal${NC}"
    echo
    echo -e "   ${YELLOW}2.${NC} Configure o PMG:"
    echo -e "      ${GREEN}pmg configure${NC}"
    echo
    echo -e "   ${YELLOW}3.${NC} Teste a instalação:"
    echo -e "      ${GREEN}pmg test${NC}"
    echo
    echo -e "   ${YELLOW}4.${NC} Busque imagens:"
    echo -e "      ${GREEN}pmg search fortinet${NC}"
    echo -e "      ${GREEN}pmg search cisco${NC}"
    echo
    
    echo -e "${CYAN}📚 Comandos Úteis:${NC}"
    echo -e "   ${GREEN}pmg help${NC}              - Exibir ajuda completa"
    echo -e "   ${GREEN}pmg list${NC}              - Listar todas as imagens"
    echo -e "   ${GREEN}pmg search <vendor>${NC}   - Buscar por fabricante"
    echo -e "   ${GREEN}pmg pull <id>${NC}         - Baixar imagem por ID"
    echo -e "   ${GREEN}pmg install <type> <name>${NC} - Instalar imagem completa"
    echo
    
    echo -e "${CYAN}🌐 URLs Importantes:${NC}"
    echo -e "   ${BLUE}→${NC} LabHub QEMU:  ${GREEN}https://labhub.eu.org/0:/addons/qemu/${NC}"
    echo -e "   ${BLUE}→${NC} LabHub IOL:   ${GREEN}https://labhub.eu.org/0:/addons/iol/${NC}"
    echo -e "   ${BLUE}→${NC} GitHub:       ${GREEN}$GITHUB_REPO${NC}"
    echo
    
    echo -e "${CYAN}💡 Dica:${NC}"
    echo -e "   Execute ${GREEN}pmg configure${NC} para configurar:"
    echo -e "   - IP/hostname do servidor PNETLab/EVE-NG"
    echo -e "   - Credenciais SSH"
    echo -e "   - Diretório de downloads"
    echo
    
    if [[ -f "/opt/unetlab/wrappers/unl_wrapper" ]]; then
        echo -e "${GREEN}✓${NC} Sistema PNETLab/EVE-NG detectado"
    else
        echo -e "${YELLOW}⚠${NC} Para usar em servidor PNETLab/EVE-NG, execute:"
        echo -e "   ${GREEN}sudo /opt/unetlab/wrappers/unl_wrapper -a fixpermissions${NC}"
    fi
    echo
    
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}Desenvolvido com ❤️  para a comunidade de Network Labs${NC}"
    echo -e "${MAGENTA}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

################################################################################
# Main
################################################################################

main() {
    print_banner
    
    log_step "Iniciando instalação automatizada..."
    echo
    
    # Verificações
    check_root
    check_distro
    echo
    
    # Dependências
    install_dependencies
    
    # Download
    download_from_github
    echo
    
    # Extração
    extract_files
    echo
    
    # Instalação
    install_files
    echo
    
    # Configuração
    configure_shell
    echo
    
    # Permissões PNETLab
    apply_pnetlab_permissions
    echo
    
    # Testes
    test_installation
    echo
    
    # Limpeza
    cleanup
    echo
    
    # Resumo
    print_summary
    
    # Configuração opcional
    echo -e "${YELLOW}Deseja configurar agora? (y/n):${NC} "
    read -r configure_now
    if [[ "$configure_now" =~ ^[Yy]$ ]]; then
        echo
        source ~/.bashrc 2>/dev/null || export PATH="$PATH:$INSTALL_DIR"
        "$INSTALL_DIR/$SCRIPT_NAME" configure
    else
        echo
        log_info "Você pode configurar depois com: ${GREEN}pmg configure${NC}"
    fi
    
    echo
    log_success "Instalação concluída! Aproveite o PNETLab Manager v3.0! 🚀"
    echo
}

# Trap para garantir limpeza em caso de erro
trap cleanup EXIT

# Executar
main "$@"
