#!/bin/bash

################################################################################
# PNETLab Manager v3.0 - Desinstalador
# Remove completamente o PMG do sistema
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configurações
INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="pmg"
CONFIG_DIR="${HOME}/.pmg"
CACHE_DIR="${HOME}/.pmg-cache"
DOWNLOAD_DIR="${HOME}/pmg-downloads"

################################################################################
# Funções de Log
################################################################################

print_banner() {
    echo -e "${RED}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║         PNETLab Manager v3.0 - Desinstalador                 ║
║         Remove todos os arquivos e configurações             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
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

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

################################################################################
# Funções de Desinstalação
################################################################################

check_installation() {
    log_step "Verificando instalação..."
    
    local found=0
    
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        log_info "Script encontrado: $INSTALL_DIR/$SCRIPT_NAME"
        found=1
    fi
    
    if [[ -f "$INSTALL_DIR/labhub_parser.py" ]]; then
        log_info "Parser encontrado: $INSTALL_DIR/labhub_parser.py"
        found=1
    fi
    
    if [[ -d "$CONFIG_DIR" ]]; then
        log_info "Configurações encontradas: $CONFIG_DIR"
        found=1
    fi
    
    if [[ -d "$CACHE_DIR" ]]; then
        log_info "Cache encontrado: $CACHE_DIR"
        found=1
    fi
    
    if [[ -d "$DOWNLOAD_DIR" ]]; then
        log_info "Downloads encontrados: $DOWNLOAD_DIR"
        found=1
    fi
    
    if [[ $found -eq 0 ]]; then
        log_warning "PMG não está instalado neste sistema"
        exit 0
    fi
    
    echo
}

confirm_uninstall() {
    echo -e "${YELLOW}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}ATENÇÃO: Esta ação não pode ser desfeita!${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Os seguintes itens serão removidos:"
    echo
    
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        echo -e "  ${RED}✗${NC} Script principal: $INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    if [[ -f "$INSTALL_DIR/labhub_parser.py" ]]; then
        echo -e "  ${RED}✗${NC} Parser Python: $INSTALL_DIR/labhub_parser.py"
    fi
    
    if [[ -d "$CONFIG_DIR" ]]; then
        echo -e "  ${RED}✗${NC} Configurações: $CONFIG_DIR"
    fi
    
    if [[ -d "$CACHE_DIR" ]]; then
        echo -e "  ${RED}✗${NC} Cache: $CACHE_DIR"
    fi
    
    if [[ -d "$DOWNLOAD_DIR" ]]; then
        local size=$(du -sh "$DOWNLOAD_DIR" 2>/dev/null | cut -f1)
        echo -e "  ${RED}✗${NC} Downloads: $DOWNLOAD_DIR (${YELLOW}$size${NC})"
    fi
    
    echo -e "  ${RED}✗${NC} Entradas no ~/.bashrc"
    echo
    
    echo -e "${YELLOW}Deseja realmente desinstalar? (digite 'yes' para confirmar):${NC} "
    read -r confirmation
    
    if [[ "$confirmation" != "yes" ]]; then
        log_info "Desinstalação cancelada"
        exit 0
    fi
    
    echo
}

remove_files() {
    log_step "Removendo arquivos..."
    
    # Remover script principal
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        rm -f "$INSTALL_DIR/$SCRIPT_NAME"
        log_success "Script removido: $SCRIPT_NAME"
    fi
    
    # Remover parser
    if [[ -f "$INSTALL_DIR/labhub_parser.py" ]]; then
        rm -f "$INSTALL_DIR/labhub_parser.py"
        log_success "Parser removido"
    fi
    
    # Remover possíveis arquivos compilados Python
    if [[ -f "$INSTALL_DIR/labhub_parser.pyc" ]]; then
        rm -f "$INSTALL_DIR/labhub_parser.pyc"
    fi
    
    if [[ -d "$INSTALL_DIR/__pycache__" ]]; then
        rm -rf "$INSTALL_DIR/__pycache__"
    fi
    
    echo
}

remove_config() {
    log_step "Removendo configurações..."
    
    if [[ -d "$CONFIG_DIR" ]]; then
        rm -rf "$CONFIG_DIR"
        log_success "Configurações removidas: $CONFIG_DIR"
    else
        log_info "Nenhuma configuração encontrada"
    fi
    
    echo
}

remove_cache() {
    log_step "Removendo cache..."
    
    if [[ -d "$CACHE_DIR" ]]; then
        local size=$(du -sh "$CACHE_DIR" 2>/dev/null | cut -f1)
        rm -rf "$CACHE_DIR"
        log_success "Cache removido: $size liberados"
    else
        log_info "Nenhum cache encontrado"
    fi
    
    echo
}

remove_downloads() {
    log_step "Removendo downloads..."
    
    if [[ -d "$DOWNLOAD_DIR" ]]; then
        echo -e "${YELLOW}Os downloads estão em: $DOWNLOAD_DIR${NC}"
        
        local size=$(du -sh "$DOWNLOAD_DIR" 2>/dev/null | cut -f1)
        local count=$(find "$DOWNLOAD_DIR" -type f 2>/dev/null | wc -l)
        
        echo -e "  ${BLUE}→${NC} Tamanho total: ${YELLOW}$size${NC}"
        echo -e "  ${BLUE}→${NC} Total de arquivos: ${YELLOW}$count${NC}"
        echo
        
        echo -e "${YELLOW}Deseja remover os downloads também? (y/n):${NC} "
        read -r remove_dl
        
        if [[ "$remove_dl" =~ ^[Yy]$ ]]; then
            rm -rf "$DOWNLOAD_DIR"
            log_success "Downloads removidos: $size liberados"
        else
            log_info "Downloads mantidos em: $DOWNLOAD_DIR"
        fi
    else
        log_info "Nenhum download encontrado"
    fi
    
    echo
}

clean_bashrc() {
    log_step "Limpando ~/.bashrc..."
    
    local bashrc="${HOME}/.bashrc"
    local backup="${HOME}/.bashrc.pmg-backup-$(date +%Y%m%d-%H%M%S)"
    
    if [[ -f "$bashrc" ]]; then
        # Criar backup
        cp "$bashrc" "$backup"
        log_info "Backup criado: $backup"
        
        # Remover linhas relacionadas ao PMG
        local removed=0
        
        if grep -q "PNETLab Manager" "$bashrc" 2>/dev/null; then
            sed -i '/# PNETLab Manager/d' "$bashrc"
            ((removed++))
        fi
        
        if grep -q "export PATH=.*\.local\/bin" "$bashrc" 2>/dev/null; then
            sed -i '/export PATH=.*\.local\/bin/d' "$bashrc"
            ((removed++))
        fi
        
        if grep -q "alias pmg=" "$bashrc" 2>/dev/null; then
            sed -i '/alias pmg=/d' "$bashrc"
            ((removed++))
        fi
        
        if [[ $removed -gt 0 ]]; then
            log_success "Entradas removidas do ~/.bashrc ($removed linhas)"
        else
            log_info "Nenhuma entrada PMG encontrada no ~/.bashrc"
            rm -f "$backup"
        fi
    fi
    
    echo
}

verify_removal() {
    log_step "Verificando remoção..."
    
    local issues=0
    
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        log_error "Script ainda existe: $INSTALL_DIR/$SCRIPT_NAME"
        ((issues++))
    fi
    
    if [[ -f "$INSTALL_DIR/labhub_parser.py" ]]; then
        log_error "Parser ainda existe"
        ((issues++))
    fi
    
    if [[ -d "$CONFIG_DIR" ]]; then
        log_error "Configurações ainda existem"
        ((issues++))
    fi
    
    if [[ -d "$CACHE_DIR" ]]; then
        log_error "Cache ainda existe"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        log_success "Todos os componentes foram removidos"
    else
        log_warning "Alguns componentes não foram removidos ($issues)"
    fi
    
    echo
}

print_summary() {
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║            ✓ DESINSTALAÇÃO CONCLUÍDA!                        ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    log_info "PNETLab Manager v3.0 foi removido do sistema"
    echo
    
    log_info "Para reinstalar no futuro, execute:"
    echo -e "   ${GREEN}wget -qO- https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh | bash${NC}"
    echo
    
    log_warning "Recarregue seu shell ou abra um novo terminal:"
    echo -e "   ${GREEN}source ~/.bashrc${NC}"
    echo
    
    echo -e "${CYAN}Obrigado por usar o PNETLab Manager!${NC}"
    echo
}

################################################################################
# Main
################################################################################

main() {
    print_banner
    echo
    
    check_installation
    confirm_uninstall
    
    remove_files
    remove_config
    remove_cache
    remove_downloads
    clean_bashrc
    verify_removal
    
    print_summary
}

# Executar
main "$@"
