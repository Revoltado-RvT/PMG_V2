# 📦 Guia de Instalação - PMG v3.2

Este guia fornece instruções detalhadas para instalar o PMG em seu sistema PNETLab.

## 📋 Pré-requisitos

Antes de instalar o PMG, certifique-se de que seu sistema atende aos seguintes requisitos:

- ✅ Sistema operacional: Ubuntu/Debian Linux
- ✅ PNETLab instalado (recomendado)
- ✅ Acesso root ou sudo
- ✅ Conexão ativa com a internet
- ✅ Mínimo de 1GB de espaço livre em disco

## 🚀 Métodos de Instalação

### Método 1: Instalação Rápida com wget (Recomendado)

```bash
wget -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg && chmod +x /usr/sbin/pmg && pmg
```

**Vantagens:**
- ✅ Instalação em uma única linha
- ✅ Mais rápido
- ✅ Requer apenas wget

### Método 2: Instalação Rápida com curl

```bash
curl -o /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg && chmod +x /usr/sbin/pmg && pmg
```

**Vantagens:**
- ✅ Instalação em uma única linha
- ✅ Útil se wget não estiver disponível

### Método 3: Script de Instalação Automática

```bash
# Baixar e executar o instalador
bash <(curl -sL https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh)
```

ou

```bash
# Baixar primeiro, depois executar
wget https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh
chmod +x auto-install-pmg.sh
sudo ./auto-install-pmg.sh
```

**Vantagens:**
- ✅ Instalação guiada
- ✅ Verifica dependências
- ✅ Testa a instalação automaticamente
- ✅ Mensagens coloridas e informativas

### Método 4: Instalação Manual Passo a Passo

#### Passo 1: Clonar o Repositório

```bash
cd /tmp
git clone https://github.com/Revoltado-RvT/PMG_V2.git
cd PMG_V2
```

#### Passo 2: Copiar o Script Principal

```bash
sudo cp pmg /usr/sbin/pmg
```

#### Passo 3: Tornar Executável

```bash
sudo chmod +x /usr/sbin/pmg
```

#### Passo 4: Criar Diretório de Configuração

```bash
sudo mkdir -p /opt/pmg
```

#### Passo 5: Executar PMG pela Primeira Vez

```bash
sudo pmg
```

**Vantagens:**
- ✅ Controle total sobre cada etapa
- ✅ Útil para troubleshooting
- ✅ Permite customizações

## 🔧 Verificação da Instalação

Após a instalação, verifique se tudo está funcionando corretamente:

### 1. Verificar Versão

```bash
pmg version
```

**Saída esperada:**
```
PMG v3.2
Modified from ishare2-cli
API: https://labhub.eu.org/0:/addons/
```

### 2. Testar Conectividade

```bash
pmg test
```

**Saída esperada:**
```
[-] Running connection tests...
[-] Checking if LabHub Main is reachable...
[+] LabHub Main is reachable.
[-] Checking if LabHub Drive is reachable...
[+] LabHub Drive is reachable.
[-] Checking if GitHub is reachable...
[+] GitHub is reachable.
[-] Checking if Google DNS is reachable...
[+] Google DNS is reachable.
[+] All services are reachable.
```

### 3. Buscar Imagens de Teste

```bash
pmg search qemu win
```

**Saída esperada:**
Deve listar várias imagens Windows disponíveis.

## 📁 Estrutura de Arquivos Após Instalação

```
/usr/sbin/pmg           # Binário principal do PMG
/opt/pmg/               # Diretório de dados do PMG
├── pmg.conf            # Arquivo de configuração
├── pmg.log             # Arquivo de logs
├── labhub.json         # Cache do índice de imagens
└── tmp/                # Arquivos temporários
```

## ⚙️ Configuração Pós-Instalação

### Configuração Automática

O PMG cria automaticamente um arquivo de configuração padrão em `/opt/pmg/pmg.conf` na primeira execução.

### Configuração Manual (Opcional)

Se desejar personalizar as configurações, edite o arquivo:

```bash
sudo nano /opt/pmg/pmg.conf
```

**Opções disponíveis:**

```bash
USE_ARIA2C=false        # true: usar aria2c (mais rápido), false: usar wget
SSL_CHECK=true          # true: verificar SSL, false: ignorar verificação SSL
CHANNEL=main            # Canal de atualização (main/dev)
```

**Exemplo de configuração otimizada:**

```bash
USE_ARIA2C=true         # Ativar downloads mais rápidos
SSL_CHECK=true          # Manter segurança
CHANNEL=main            # Usar versão estável
```

### Instalar aria2c para Downloads Mais Rápidos (Opcional)

```bash
sudo apt update
sudo apt install aria2 -y
```

Depois, edite a configuração:

```bash
sudo nano /opt/pmg/pmg.conf
```

Altere para:
```bash
USE_ARIA2C=true
```

## 🔍 Resolução de Problemas na Instalação

### Problema 1: "Permission denied"

**Erro:**
```
-bash: /usr/sbin/pmg: Permission denied
```

**Solução:**
```bash
sudo chmod +x /usr/sbin/pmg
```

### Problema 2: "command not found"

**Erro:**
```
pmg: command not found
```

**Solução:**
```bash
# Verificar se o arquivo existe
ls -la /usr/sbin/pmg

# Se não existir, reinstalar
sudo wget -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg
sudo chmod +x /usr/sbin/pmg
```

### Problema 3: Erro ao baixar do GitHub

**Erro:**
```
Failed to download PMG
```

**Possíveis Soluções:**

1. **Verificar conectividade com GitHub:**
```bash
ping github.com
```

2. **Tentar com curl em vez de wget:**
```bash
curl -o /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg
```

3. **Verificar firewall:**
```bash
sudo ufw status
```

4. **Usar proxy se necessário:**
```bash
export http_proxy=http://seu_proxy:porta
export https_proxy=http://seu_proxy:porta
```

### Problema 4: Falta de dependências

**Erro:**
```
jq: command not found
```

**Solução:**
```bash
sudo apt update
sudo apt install -y curl wget jq unzip unrar tree
```

### Problema 5: Erro de SSL

**Erro:**
```
SSL certificate problem
```

**Solução temporária (não recomendado para produção):**
```bash
# Usar wget com --no-check-certificate
wget --no-check-certificate -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg
```

**Solução adequada:**
```bash
# Atualizar certificados
sudo apt update
sudo apt install ca-certificates
sudo update-ca-certificates
```

## 🔄 Atualização

Para atualizar o PMG para a versão mais recente:

```bash
# Baixar nova versão
sudo wget -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg

# Tornar executável
sudo chmod +x /usr/sbin/pmg

# Verificar nova versão
pmg version
```

## 🗑️ Desinstalação

### Método 1: Script Automático

```bash
bash <(curl -sL https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/uninstall-pmg.sh)
```

### Método 2: Manual

```bash
# Remover binário
sudo rm /usr/sbin/pmg

# Remover diretório de configuração (opcional)
sudo rm -rf /opt/pmg
```

## 📊 Verificação de Integridade

Após a instalação, você pode verificar a integridade do arquivo:

```bash
# Ver informações do arquivo
ls -lh /usr/sbin/pmg

# Verificar se é executável
file /usr/sbin/pmg

# Ver primeiras linhas do script
head -n 20 /usr/sbin/pmg
```

## 🎯 Próximos Passos

Após instalar com sucesso:

1. **Explorar comandos:**
```bash
pmg help
```

2. **Buscar imagens:**
```bash
pmg search qemu
```

3. **Baixar sua primeira imagem:**
```bash
pmg search qemu win
pmg pull qemu [ID]
```

4. **Ler a documentação completa:**
```bash
# No repositório
cat README.md
```

## 📞 Suporte

Se encontrar problemas durante a instalação:

1. **Verificar logs:**
```bash
sudo tail -n 50 /opt/pmg/pmg.log
```

2. **Relatar problema:**
   - [GitHub Issues](https://github.com/Revoltado-RvT/PMG_V2/issues)
   - [Telegram @NetLabHub](https://t.me/NetLabHub)

3. **Fornecer informações:**
   - Versão do sistema: `lsb_release -a`
   - Versão do PMG: `pmg version`
   - Logs: Conteúdo de `/opt/pmg/pmg.log`

---

✅ **Instalação concluída com sucesso!** Aproveite o PMG v3.2!
