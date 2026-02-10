#!/bin/bash

# PNETLab Image Manager v3.1 - FIXED
# Correções críticas para busca e download
# Data: 2025-02-10

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# URLs base - LabHub.eu.org com fallback
BASE_URL="https://labhub.eu.org"
DRIVE_URL="https://drive.labhub.eu.org/0:/addons"

# URLs alternativas (fallback)
ALT_BASE_URL="https://pnetlab.com/pages/download"
ALT_DRIVE_URL="https://raw.githubusercontent.com/pnetlaborg/pnetlab_main_repo/master"

# Configurações
CONFIG_FILE="$HOME/.pmg/config.conf"
DOWNLOAD_DIR="$HOME/pmg-downloads"
CACHE_DIR="$HOME/.pmg-cache"
IMAGE_LIST_CACHE="$CACHE_DIR/images.cache"
CACHE_DURATION=86400  # 24 horas

# Diretórios PNETLab
PNETLAB_QEMU_DIR="/opt/unetlab/addons/qemu"
PNETLAB_IOL_DIR="/opt/unetlab/addons/iol/bin"
PNETLAB_DYNAMIPS_DIR="/opt/unetlab/addons/dynamips"

# Fabricantes conhecidos (CORRIGIDO - padrões mais simples)
declare -A VENDORS=(
    ["cisco"]="cisco|vios|iosv|csr|nxos|xrv|asa|asav|ftd|wsa|esa|ise"
    ["juniper"]="junos|vmx|vsrx|vqfx|vjunos|olive"
    ["paloalto"]="panos|pa-vm|panorama"
    ["fortinet"]="fortinet|fortigate|fortiweb|fortimail|fortianalyzer|fortimanager|fac|fad|faz|fmg|fgt"
    ["checkpoint"]="checkpoint|gaia|cloudguard"
    ["arista"]="veos|ceos|arista"
    ["mikrotik"]="chr|routeros|mikrotik"
    ["pfsense"]="pfsense|opnsense"
    ["f5"]="bigip|f5"
    ["sophos"]="sophos|xg|utm"
    ["sonicwall"]="sonicwall|nsa|tz"
    ["watchguard"]="watchguard|firebox"
    ["zabbix"]="zabbix"
    ["zeus"]="zeus|m600v|m100v"
    ["firepower"]="ftd|firepower|fmc"
    ["windows"]="win-|winserver|windows"
    ["linux"]="ubuntu|debian|centos|alpine|kali|linux"
)

# ============================================
# FUNÇÕES AUXILIARES
# ============================================

show_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║          PMG - PNETLab Manager v3.1 FIXED                  ║
║          Advanced Image Management Tool                    ║
║          Integration with LabHub.eu.org                    ║
╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_debug() {
    if [[ "$DEBUG" == "1" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $1" >&2
    fi
}

# Função para criar estrutura de diretórios
init_dirs() {
    mkdir -p "$DOWNLOAD_DIR"/{qemu,iol,dynamips,docker}
    mkdir -p "$CACHE_DIR"
    mkdir -p "$(dirname "$CONFIG_FILE")"
}

# Função para carregar configurações
load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        source "$CONFIG_FILE"
        log_debug "Configurações carregadas de $CONFIG_FILE"
    else
        log_debug "Arquivo de configuração não encontrado"
    fi
}

# Converter bytes para formato legível
bytes_to_human() {
    local bytes=$1
    if [[ -z "$bytes" ]] || [[ ! "$bytes" =~ ^[0-9]+$ ]]; then
        echo "N/A"
        return
    fi
    
    if command -v numfmt &>/dev/null; then
        numfmt --to=iec-i --suffix=B "$bytes" 2>/dev/null || echo "$bytes B"
    else
        local units=("B" "KB" "MB" "GB" "TB")
        local unit=0
        local size=$bytes
        
        while (( size >= 1024 )) && (( unit < 4 )); do
            size=$((size / 1024))
            ((unit++))
        done
        
        echo "$size ${units[$unit]}"
    fi
}

# ============================================
# TESTE DE CONECTIVIDADE
# ============================================

test_labhub_connection() {
    log_debug "Testando conexão com LabHub..."
    
    # Testar URL principal
    if curl -s --connect-timeout 5 --max-time 10 -I "$BASE_URL" &>/dev/null; then
        log_debug "LabHub acessível: $BASE_URL"
        return 0
    fi
    
    log_debug "LabHub principal não acessível, tentando drive..."
    
    # Testar URL do drive
    if curl -s --connect-timeout 5 --max-time 10 -I "$DRIVE_URL/qemu/" &>/dev/null; then
        log_debug "LabHub drive acessível: $DRIVE_URL"
        return 0
    fi
    
    log_warning "LabHub não está acessível no momento"
    return 1
}

# ============================================
# PARSE DO HTML DO LABHUB
# ============================================

parse_labhub_html() {
    local url=$1
    local output_file=$2
    
    log_debug "Fazendo parse de: $url"
    
    # Criar diretório de saída se não existir
    mkdir -p "$(dirname "$output_file")"
    
    # Baixar HTML com tratamento de erros
    local html_content
    html_content=$(curl -s --connect-timeout 10 --max-time 30 -L "$url" 2>/dev/null)
    
    if [[ -z "$html_content" ]]; then
        log_error "Falha ao baixar conteúdo de: $url"
        touch "$output_file"
        return 1
    fi
    
    log_debug "HTML baixado, fazendo parse..."
    
    # Usar o parser Python externo se disponível
    local parser_script="$(dirname "$0")/labhub_parser.py"
    
    if [[ -f "$parser_script" ]] && [[ -x "$parser_script" ]]; then
        echo "$html_content" | python3 "$parser_script" > "$output_file" 2>/dev/null
        local found=$(wc -l < "$output_file" 2>/dev/null || echo "0")
        log_debug "Parser externo encontrou $found imagens"
        return 0
    fi
    
    # Fallback: parser inline simplificado
    log_debug "Usando parser inline (fallback)"
    
    echo "$html_content" | python3 << 'PYTHON_PARSER' > "$output_file" 2>/dev/null
import sys
import re
from html.parser import HTMLParser

class SimpleLabHubParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.in_tbody = False
        self.in_tr = False
        self.in_td = False
        self.in_a = False
        self.td_count = 0
        self.current_row = {}
        self.results = []
        
    def handle_starttag(self, tag, attrs):
        if tag == 'tbody':
            self.in_tbody = True
        elif tag == 'tr' and self.in_tbody:
            self.in_tr = True
            self.td_count = 0
            self.current_row = {}
        elif tag == 'td' and self.in_tr:
            self.in_td = True
            self.td_count += 1
        elif tag == 'a' and self.in_td and self.td_count == 1:
            self.in_a = True
            for attr, value in attrs:
                if attr == 'href':
                    filename = value.split('/')[-1].replace('%20', ' ')
                    if filename and filename not in ['Parent', '..', '']:
                        self.current_row['name'] = filename
                        
    def handle_data(self, data):
        if not self.in_tr or not self.in_td:
            return
        data = data.strip()
        if not data:
            return
        
        # Coluna 3: Tamanho
        if self.td_count == 3 and 'name' in self.current_row:
            match = re.search(r'(\d+(?:\.\d+)?)\s*(B|KB|MB|GB|TB|PB)', data, re.IGNORECASE)
            if match:
                size_value = float(match.group(1))
                size_unit = match.group(2).upper()
                
                multipliers = {
                    'B': 1, 'KB': 1024, 'MB': 1024**2,
                    'GB': 1024**3, 'TB': 1024**4, 'PB': 1024**5
                }
                
                size_bytes = int(size_value * multipliers.get(size_unit, 1))
                self.current_row['size'] = size_bytes
                    
    def handle_endtag(self, tag):
        if tag == 'a':
            self.in_a = False
        elif tag == 'td':
            self.in_td = False
        elif tag == 'tr' and self.in_tr:
            self.in_tr = False
            if 'name' in self.current_row and 'size' in self.current_row:
                print(f"{self.current_row['name']}|{self.current_row['size']}")
        elif tag == 'tbody':
            self.in_tbody = False

parser = SimpleLabHubParser()
parser.feed(sys.stdin.read())
PYTHON_PARSER

    local found=$(wc -l < "$output_file" 2>/dev/null || echo "0")
    log_debug "Parser inline encontrou $found imagens"
    
    return 0
}

# ============================================
# CACHE DE IMAGENS
# ============================================

update_cache() {
    local type=${1:-all}
    
    log_info "Atualizando cache de imagens ($type)..."
    
    # Testar conectividade primeiro
    if ! test_labhub_connection; then
        log_error "LabHub não está acessível. Verifique sua conexão com a internet."
        return 1
    fi
    
    local updated=0
    
    case $type in
        qemu|all)
            log_debug "Baixando lista de imagens QEMU..."
            if parse_labhub_html "$DRIVE_URL/qemu/" "$CACHE_DIR/qemu.list"; then
                ((updated++))
            fi
            ;;
    esac
    
    case $type in
        iol|all)
            log_debug "Baixando lista de imagens IOL..."
            if parse_labhub_html "$DRIVE_URL/iol/" "$CACHE_DIR/iol.list"; then
                ((updated++))
            fi
            ;;
    esac
    
    case $type in
        dynamips|all)
            log_debug "Baixando lista de imagens Dynamips..."
            if parse_labhub_html "$DRIVE_URL/dynamips/" "$CACHE_DIR/dynamips.list"; then
                ((updated++))
            fi
            ;;
    esac
    
    if [[ $updated -gt 0 ]]; then
        touch "$IMAGE_LIST_CACHE"
        log_success "Cache atualizado! ($updated tipos)"
    else
        log_error "Falha ao atualizar cache"
        return 1
    fi
}

check_cache() {
    if [[ -f "$IMAGE_LIST_CACHE" ]]; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$IMAGE_LIST_CACHE" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt $CACHE_DURATION ]]; then
            log_debug "Cache válido (idade: $((cache_age / 3600))h)"
            return 0
        fi
        log_debug "Cache expirado (idade: $((cache_age / 3600))h)"
    fi
    return 1
}

# ============================================
# BUSCA DE IMAGENS - VERSÃO CORRIGIDA
# ============================================

search_images() {
    local search_term="$1"
    local type="${2:-all}"
    
    show_banner
    
    # Atualizar cache se necessário
    if ! check_cache; then
        if ! update_cache "$type"; then
            log_error "Não foi possível atualizar o cache. Verifique sua conexão."
            return 1
        fi
    fi
    
    if [[ -n "$search_term" ]]; then
        echo -e "${CYAN} Searching for \"$search_term\" (type: $type)${NC}"
    else
        echo -e "${CYAN} Listing all available images (type: $type)${NC}"
    fi
    echo "================================================="
    
    local found=0
    local id=1
    
    # Criar arquivo temporário com resultados
    local results_file="/tmp/pmg-search-$$.txt"
    > "$results_file"
    
    # Converter termo de busca para minúsculas para comparação case-insensitive
    local search_lower=$(echo "$search_term" | tr '[:upper:]' '[:lower:]')
    
    # Buscar por fabricante conhecido
    local vendor_pattern=""
    if [[ -n "${VENDORS[$search_lower]}" ]]; then
        vendor_pattern="${VENDORS[$search_lower]}"
        log_info "Buscando imagens do fabricante: ${search_lower^^}"
        log_debug "Padrão de busca: $vendor_pattern"
        echo
    else
        vendor_pattern="$search_term"
    fi
    
    # Função interna para buscar em um tipo
    search_in_type() {
        local stype=$1
        local cache_file="$CACHE_DIR/${stype}.list"
        
        if [[ ! -f "$cache_file" ]]; then
            log_debug "Cache file não encontrado: $cache_file"
            return
        fi
        
        local count=$(wc -l < "$cache_file" 2>/dev/null || echo "0")
        log_debug "Processando $count imagens do tipo $stype..."
        
        while IFS='|' read -r image size_bytes; do
            # Pular linhas vazias
            [[ -z "$image" ]] && continue
            
            # Converter nome da imagem para minúsculas
            local image_lower=$(echo "$image" | tr '[:upper:]' '[:lower:]')
            
            # Filtrar por termo de busca (case insensitive)
            if [[ -z "$vendor_pattern" ]] || echo "$image_lower" | grep -qiE "$vendor_pattern"; then
                # Converter tamanho para formato legível
                local size=$(bytes_to_human "$size_bytes")
                
                # Salvar resultado
                echo "$id|$image|$stype|$size" >> "$results_file"
                ((id++))
                ((found++))
            fi
        done < "$cache_file"
    }
    
    # Buscar nos tipos apropriados
    case $type in
        all)
            search_in_type "qemu"
            search_in_type "iol"
            search_in_type "dynamips"
            ;;
        *)
            search_in_type "$type"
            ;;
    esac
    
    # Exibir resultados
    if [[ $found -eq 0 ]]; then
        log_warning "Nenhuma imagem encontrada para: $search_term"
        
        # Sugestões de busca
        echo
        log_info "Dicas:"
        echo "  • Tente termos mais simples (ex: 'forti' ao invés de 'fortigate')"
        echo "  • Verifique se o cache está atualizado: pmg cache-update"
        echo "  • Liste tudo: pmg list"
        echo "  • Busque por tipo: pmg search <termo> qemu"
        echo
        
        rm -f "$results_file"
        return 1
    fi
    
    # Cabeçalho da tabela
    printf "%-4s %-40s %-10s %s\n" "ID" "NAME" "TYPE" "SIZE"
    printf "%-4s %-40s %-10s %s\n" "--" "----" "----" "----"
    
    # Exibir resultados
    while IFS='|' read -r id name type size; do
        printf "%-4s %-40s %-10s %s\n" "$id" "$name" "$type" "$size"
    done < "$results_file"
    
    echo
    log_success "Encontradas $found imagens"
    
    # Salvar resultados para uso posterior
    cp "$results_file" "$CACHE_DIR/last_search.txt"
    rm -f "$results_file"
}

# ============================================
# DOWNLOAD DE IMAGEM - VERSÃO CORRIGIDA
# ============================================

download_image() {
    local category=$1
    local filename=$2
    
    if [[ -z "$category" ]] || [[ -z "$filename" ]]; then
        log_error "Uso: download <tipo> <arquivo> OU pull <id>"
        return 1
    fi
    
    # URL base conforme categoria
    local url=""
    case $category in
        dynamips)
            url="$DRIVE_URL/dynamips/$filename"
            ;;
        iol)
            url="$DRIVE_URL/iol/$filename"
            ;;
        qemu)
            url="$DRIVE_URL/qemu/$filename"
            ;;
        *)
            log_error "Categoria inválida. Use: dynamips, iol, qemu"
            return 1
            ;;
    esac
    
    mkdir -p "$DOWNLOAD_DIR/$category"
    local dest="$DOWNLOAD_DIR/$category/$filename"
    
    # Verificar se já existe
    if [[ -f "$dest" ]] && [[ -s "$dest" ]]; then
        log_warning "Arquivo já existe: $dest"
        local file_size=$(stat -c%s "$dest" 2>/dev/null || echo "0")
        log_info "Tamanho: $(bytes_to_human $file_size)"
        
        read -p "Deseja baixar novamente? (y/n): " overwrite
        if [[ "$overwrite" != "y" ]]; then
            log_info "Download cancelado"
            return 0
        fi
    fi
    
    log_info "Baixando de: $url"
    log_info "Salvando em: $dest"
    echo
    
    # Download com wget (melhor progress bar)
    log_info "Download Progress:"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if command -v wget &>/dev/null; then
        if wget --show-progress --progress=bar:force:noscroll -c -O "$dest" "$url" 2>&1; then
            echo
            
            # Verificar se o arquivo foi realmente baixado
            if [[ -f "$dest" ]] && [[ -s "$dest" ]]; then
                local file_size=$(stat -c%s "$dest" 2>/dev/null || echo "0")
                log_success "Download concluído: $filename"
                log_success "Tamanho do arquivo: $(bytes_to_human $file_size)"
                return 0
            else
                log_error "Arquivo baixado está vazio ou corrompido"
                rm -f "$dest"
                return 1
            fi
        else
            log_error "Falha no download com wget"
            rm -f "$dest"
            return 1
        fi
    elif command -v curl &>/dev/null; then
        if curl -# -L -C - -o "$dest" "$url" 2>&1; then
            echo
            
            if [[ -f "$dest" ]] && [[ -s "$dest" ]]; then
                local file_size=$(stat -c%s "$dest" 2>/dev/null || echo "0")
                log_success "Download concluído: $filename"
                log_success "Tamanho do arquivo: $(bytes_to_human $file_size)"
                return 0
            else
                log_error "Arquivo baixado está vazio ou corrompido"
                rm -f "$dest"
                return 1
            fi
        else
            log_error "Falha no download com curl"
            rm -f "$dest"
            return 1
        fi
    else
        log_error "wget ou curl não encontrados. Instale um deles."
        return 1
    fi
}

# ============================================
# DOWNLOAD POR ID
# ============================================

pull_by_id() {
    local id=$1
    local search_file="$CACHE_DIR/last_search.txt"
    
    if [[ ! -f "$search_file" ]]; then
        log_error "Execute uma busca primeiro com: search <termo>"
        return 1
    fi
    
    # Buscar imagem pelo ID
    local result=$(grep "^$id|" "$search_file")
    
    if [[ -z "$result" ]]; then
        log_error "ID $id não encontrado nos resultados da última busca"
        log_info "Execute 'search' novamente para ver os IDs disponíveis"
        return 1
    fi
    
    local filename=$(echo "$result" | cut -d'|' -f2)
    local type=$(echo "$result" | cut -d'|' -f3)
    
    log_info "Baixando imagem ID $id: $filename ($type)"
    echo
    
    download_image "$type" "$filename"
}

# ============================================
# MENU DE AJUDA
# ============================================

show_help() {
    show_banner
    
    cat << 'EOF'
COMANDOS DISPONÍVEIS:

  BUSCA E LISTAGEM:
    search <termo> [tipo]   - Buscar imagens (tipo: qemu, iol, dynamips, all)
    list [tipo]             - Listar todas as imagens disponíveis
    cache-update [tipo]     - Atualizar cache de imagens

  DOWNLOAD:
    pull <id>               - Baixar imagem por ID (use após search)
    download <tipo> <nome>  - Download direto por nome

  CONFIGURAÇÃO:
    configure               - Configurar PMG interativamente
    test                    - Testar conexões

  UTILITÁRIOS:
    help                    - Exibir esta ajuda
    version                 - Versão do PMG

EXEMPLOS:

  # Buscar imagens Fortinet
  pmg search fortinet

  # Buscar apenas imagens QEMU
  pmg search cisco qemu

  # Baixar por ID
  pmg search fortinet
  pmg pull 1

  # Download direto
  pmg download qemu fortinet-5.2

  # Atualizar cache
  pmg cache-update

FABRICANTES SUPORTADOS:
  cisco, juniper, fortinet, paloalto, checkpoint, arista,
  mikrotik, pfsense, f5, sophos, sonicwall, watchguard,
  zabbix, zeus, firepower, windows, linux

MAIS INFORMAÇÕES:
  https://github.com/Revoltado-RvT/PMG_V2

EOF
}

# ============================================
# MAIN
# ============================================

main() {
    init_dirs
    load_config
    
    case "${1:-help}" in
        configure|config)
            log_error "Função configure ainda não implementada nesta versão de correção"
            log_info "Configure manualmente editando: $CONFIG_FILE"
            ;;
        test)
            show_banner
            log_info "Testando conectividade..."
            if test_labhub_connection; then
                log_success "LabHub acessível!"
            else
                log_error "LabHub não acessível"
                log_info "Verifique sua conexão com a internet"
            fi
            ;;
        search|find)
            shift
            search_images "$@"
            ;;
        list|ls)
            shift
            search_images "" "${1:-all}"
            ;;
        pull)
            shift
            pull_by_id "$1"
            ;;
        download|dl)
            shift
            download_image "$@"
            ;;
        cache-update|update)
            shift
            update_cache "${1:-all}"
            ;;
        help|--help|-h)
            show_help
            ;;
        version|--version|-v)
            echo "PNETLab Manager v3.1-FIXED"
            ;;
        *)
            show_help
            ;;
    esac
}

# Executar
main "$@"
