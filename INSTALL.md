# PNETLab Manager v3.0 - Instalação Automatizada 🚀

[![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)](https://github.com/Revoltado-RvT/PMG_V2)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)

**Instalador completamente automatizado - do zero à execução em menos de 2 minutos!**

---

## 🎯 O Que Este Instalador Faz?

O `auto-install-pmg.sh` é um instalador **completamente automatizado** que:

✅ **Baixa** o projeto direto do GitHub  
✅ **Extrai** todos os arquivos automaticamente  
✅ **Instala** dependências necessárias  
✅ **Converte** arquivos para o formato correto  
✅ **Aplica** permissões automaticamente  
✅ **Configura** seu shell (PATH e alias)  
✅ **Executa** `/opt/unetlab/wrappers/unl_wrapper -a fixpermissions` (se disponível)  
✅ **Testa** a instalação  

**Tudo isso sem precisar de nenhuma interação manual!**

---

## ⚡ Instalação Rápida (Método Recomendado)

### Opção 1: Download Direto + Execução

```bash
# Baixar o instalador
wget https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh

# Dar permissão de execução
chmod +x auto-install-pmg.sh

# Executar
./auto-install-pmg.sh
```

### Opção 2: Comando Único (One-Liner)

```bash
wget -qO- https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh | bash
```

### Opção 3: Com curl

```bash
curl -sSL https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh | bash
```

---

## 📋 Pré-requisitos

### Sistema Operacional
- ✅ Ubuntu 18.04+
- ✅ Debian 9+
- ✅ CentOS 7+
- ✅ Fedora
- ✅ Qualquer distribuição Linux com bash

### Acesso
- ✅ **NÃO execute como root** (use usuário normal)
- ✅ Usuário deve ter permissão `sudo` (para instalar dependências)

---

## 🔧 O Que Será Instalado?

### Dependências Obrigatórias
- `curl` - Para downloads
- `wget` - Para downloads alternativos
- `unzip` - Para extrair arquivos
- `python3` - Para o parser

### Dependências Opcionais (instaladas se disponíveis)
- `qemu-utils` - Para conversão de imagens
- `sshpass` - Para upload SSH com senha
- `git` - Para desenvolvimento

### Arquivos Instalados
```
~/.local/bin/pmg                 # Script principal
~/.local/bin/labhub_parser.py    # Parser Python
~/.bashrc                        # Atualizado com PATH e alias
```

---

## 📖 Processo de Instalação Detalhado

Veja exatamente o que acontece quando você executa o instalador:

### 1. Verificações Iniciais
```
✓ Verifica se não está rodando como root
✓ Detecta sua distribuição Linux
✓ Identifica o gerenciador de pacotes (apt/yum)
```

### 2. Instalação de Dependências
```
✓ Verifica quais dependências já estão instaladas
✓ Instala apenas as que estão faltando
✓ Mostra progresso de cada instalação
```

### 3. Download do Projeto
```
✓ Baixa o código-fonte do GitHub
✓ URL: https://github.com/Revoltado-RvT/PMG_V2/archive/refs/heads/main.zip
✓ Salva em diretório temporário
✓ Mostra barra de progresso
```

### 4. Extração e Instalação
```
✓ Extrai arquivos do ZIP
✓ Copia para ~/.local/bin
✓ Aplica permissões de execução
✓ Verifica integridade dos arquivos
```

### 5. Configuração do Shell
```
✓ Adiciona ~/.local/bin ao PATH
✓ Cria alias 'pmg'
✓ Atualiza ~/.bashrc automaticamente
```

### 6. Permissões PNETLab/EVE-NG
```
✓ Detecta se está em servidor PNETLab/EVE-NG
✓ Executa: sudo /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
✓ Pula esta etapa se não for servidor PNETLab
```

### 7. Testes Finais
```
✓ Testa comando 'pmg help'
✓ Testa parser Python
✓ Verifica conectividade
```

### 8. Limpeza
```
✓ Remove arquivos temporários
✓ Limpa cache de download
```

---

## 🚀 Após a Instalação

### 1. Recarregue o Shell

```bash
source ~/.bashrc
```

**OU** simplesmente abra um novo terminal.

### 2. Verifique a Instalação

```bash
pmg help
```

Você deve ver o menu de ajuda completo.

### 3. Configure o PMG

```bash
pmg configure
```

Você será solicitado a informar:
- **IP/Hostname** do servidor PNETLab/EVE-NG
- **Porta SSH** (padrão: 22)
- **Usuário** (padrão: root)
- **Senha SSH**
- **Diretório de downloads** (padrão: ~/pmg-downloads)

### 4. Teste a Conexão

```bash
pmg test
```

### 5. Comece a Usar!

```bash
# Buscar imagens
pmg search fortinet
pmg search cisco iol
pmg search juniper

# Listar tudo
pmg list

# Baixar imagem
pmg pull 481

# Instalar imagem (download + conversão + upload)
pmg install qemu fortinet-5.2
```

---

## 🎯 Exemplos de Uso

### Exemplo 1: Setup Lab Fortinet

```bash
# Buscar versões disponíveis
pmg search fortinet

# Resultado:
#  ID   NAME                              TYPE  SIZE
#  481  fortinet-5.2                      qemu  33.2 MB
#  482  fortinet-FAC-v6-build0420         qemu  87.9 MB
#  ...

# Instalar FortiGate
pmg install qemu fortinet-5.2

# Verificar instalação
pmg installed | grep fortinet
```

### Exemplo 2: Lab Multi-Vendor

```bash
# Cisco IOL
pmg search cisco iol
pmg pull 10

# Juniper vMX
pmg search juniper
pmg pull 25

# Fortinet
pmg search fortinet
pmg pull 481

# Upload em lote
cd ~/pmg-downloads/qemu
for img in *.qcow2; do
    pmg upload qemu "$img"
done
```

### Exemplo 3: Conversão de Imagens Próprias

```bash
# VMware → QCOW2
pmg convert ~/Downloads/FortiGate.vmdk qcow2

# VirtualBox → QCOW2
pmg convert ~/Downloads/router.vdi qcow2

# Upload
pmg upload qemu FortiGate.qcow2
```

---

## 🛠️ Troubleshooting

### Problema: "Permission denied"

**Solução:**
```bash
chmod +x auto-install-pmg.sh
./auto-install-pmg.sh
```

### Problema: "sudo: command not found"

**Solução:**
```bash
# Como root
apt-get install sudo
usermod -aG sudo seu_usuario
# Faça logout e login novamente
```

### Problema: Busca não retorna resultados

**Solução:**
```bash
# Atualizar cache
pmg cache-update

# Limpar cache
rm -rf ~/.pmg-cache/*

# Modo debug
DEBUG=1 pmg search fortinet
```

### Problema: Download falha

**Solução:**
```bash
# Verificar conectividade
pmg test

# Verificar dependências
wget --version
curl --version
```

### Problema: Upload SSH falha

**Solução:**
```bash
# Testar SSH manualmente
ssh -p 22 root@IP_SERVIDOR

# Instalar sshpass se necessário
sudo apt-get install sshpass

# Reconfigurar
pmg configure
```

### Problema: Conversão de imagem falha

**Solução:**
```bash
# Instalar qemu-utils
sudo apt-get install qemu-utils

# Verificar instalação
qemu-img --version
```

---

## 📊 Comparação: Manual vs Automatizado

| Tarefa | Manual | Automatizado |
|--------|--------|--------------|
| Download GitHub | `git clone` ou download ZIP | ✅ Automático |
| Extrair arquivos | `unzip file.zip` | ✅ Automático |
| Instalar dependências | `sudo apt install ...` | ✅ Automático |
| Copiar arquivos | `cp file ~/.local/bin` | ✅ Automático |
| Dar permissões | `chmod +x ...` | ✅ Automático |
| Configurar PATH | Editar ~/.bashrc | ✅ Automático |
| Criar alias | Editar ~/.bashrc | ✅ Automático |
| Fix permissions | `sudo unl_wrapper ...` | ✅ Automático |
| Testar instalação | `pmg help` | ✅ Automático |
| **Tempo total** | **~10-15 min** | **~2 min** |

---

## 🔍 Verificações de Segurança

O instalador possui várias verificações de segurança:

✅ **Não permite execução como root** - evita problemas de permissões  
✅ **Verifica checksums** dos arquivos baixados  
✅ **Usa HTTPS** para todos os downloads  
✅ **Limpa arquivos temporários** após instalação  
✅ **Não modifica** arquivos de sistema críticos  
✅ **Usa diretórios de usuário** (~/.local/bin)  

---

## 📚 Comandos Disponíveis

Após a instalação, você terá acesso a todos estes comandos:

```bash
pmg help              # Ajuda completa
pmg configure         # Configuração interativa
pmg test              # Testar conectividade
pmg list              # Listar todas as imagens
pmg search <vendor>   # Buscar por fabricante
pmg pull <id>         # Baixar por ID
pmg download <type> <name>   # Download direto
pmg convert <file> <format>  # Converter imagem
pmg upload <type> <file>     # Upload para servidor
pmg install <type> <name>    # Instalação completa
pmg installed         # Ver imagens instaladas
pmg cache-update      # Atualizar cache
pmg version           # Ver versão
```

---

## 🌐 URLs Importantes

- **LabHub QEMU**: https://labhub.eu.org/0:/addons/qemu/
- **LabHub IOL**: https://labhub.eu.org/0:/addons/iol/
- **LabHub Dynamips**: https://labhub.eu.org/0:/addons/dynamips/
- **GitHub**: https://github.com/Revoltado-RvT/PMG_V2
- **PNETLab**: https://pnetlab.com
- **EVE-NG**: https://eve-ng.net

---

## 🏆 Fabricantes Suportados

```
✅ Cisco       ✅ Juniper      ✅ Fortinet     ✅ Palo Alto
✅ Checkpoint  ✅ Arista       ✅ MikroTik     ✅ pfSense
✅ F5          ✅ Sophos       ✅ SonicWall    ✅ WatchGuard
✅ Zabbix      ✅ Zeus         ✅ Firepower    ✅ Windows
✅ Linux       ... e muito mais!
```

---

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/Revoltado-RvT/PMG_V2/issues)
- **Wiki**: [GitHub Wiki](https://github.com/Revoltado-RvT/PMG_V2/wiki)

---

## 📄 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

---

## 🎓 Créditos

- **Versão Original**: ishare2 e PNETLab Manager v2.0
- **Melhorias v3.0**: Claude AI e comunidade
- **Repositório de Imagens**: [LabHub.eu.org](https://labhub.eu.org)
- **Instalador Automatizado**: Desenvolvido para simplificar instalação

---

<div align="center">

**⭐ Se este projeto te ajudou, deixe uma estrela! ⭐**

Made with ❤️ for the Network Lab Community

[Reportar Bug](https://github.com/Revoltado-RvT/PMG_V2/issues) · 
[Solicitar Feature](https://github.com/Revoltado-RvT/PMG_V2/issues) · 
[Documentação](https://github.com/Revoltado-RvT/PMG_V2/wiki)

---

## 🚀 Quick Start

```bash
# Instalação em um comando
wget -qO- https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh | bash

# Recarregar shell
source ~/.bashrc

# Configurar
pmg configure

# Começar a usar
pmg search fortinet
```

**É simples assim!** 🎉

</div>
