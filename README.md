# PMG v3.2 - PNETLab Manager

## 📋 Sobre

PMG (PNETLab Manager) é uma ferramenta CLI baseada no ishare2-cli, modificada para usar as APIs corretas do LabHub. A principal correção é o uso da URL `https://labhub.eu.org/0:/addons/` ao invés de `https://drive.labhub.eu.org/0:/addons/.org`.

## 🔧 Principais Alterações

### URLs Corrigidas
- ✅ API Base: `https://labhub.eu.org/0:/addons/`
- ✅ Drive API: `https://labhub.eu.org/0:/addons/`
- ✅ JSON Index: `https://labhub.eu.org/0:/addons/.lab-index.json`

### Melhorias
- Código limpo e otimizado
- Logs melhorados
- Verificação de conectividade
- Instalação simplificada

## 🚀 Instalação Rápida

### Método 1: Instalação em uma linha (wget)
```bash
wget -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg && chmod +x /usr/sbin/pmg && pmg
```

### Método 2: Instalação em uma linha (curl)
```bash
curl -o /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg && chmod +x /usr/sbin/pmg && pmg
```

### Método 3: Script de instalação automática
```bash
bash <(curl -sL https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh)
```

### Método 4: Instalação manual
```bash
# 1. Clone o repositório
git clone https://github.com/Revoltado-RvT/PMG_V2.git
cd PMG_V2

# 2. Copie o script para /usr/sbin
cp pmg /usr/sbin/pmg

# 3. Torne executável
chmod +x /usr/sbin/pmg

# 4. Execute
pmg
```

## 📖 Comandos

### Sintaxe
```bash
pmg [ação] [param1] [param2] [--overwrite]
```

### Ações Disponíveis

#### Buscar imagens
```bash
# Buscar todas as imagens QEMU
pmg search qemu

# Buscar imagens QEMU com filtro
pmg search qemu win

# Buscar imagens IOL
pmg search iol

# Buscar imagens Dynamips
pmg search dynamips
```

#### Baixar imagens
```bash
# Baixar uma imagem QEMU (use o ID obtido no search)
pmg pull qemu 1

# Baixar sobrescrevendo arquivo existente
pmg pull qemu 1 --overwrite

# Baixar uma imagem IOL
pmg pull iol 5

# Baixar uma imagem Dynamips
pmg pull dynamips 3
```

#### Outras funções
```bash
# Testar conectividade
pmg test

# Mostrar ajuda
pmg help

# Mostrar versão
pmg version
```

## 🔍 Exemplos de Uso

### Exemplo 1: Buscar e instalar Windows
```bash
# Buscar imagens Windows
pmg search qemu win

# Instalar Windows 10 (supondo ID 15)
pmg pull qemu 15
```

### Exemplo 2: Buscar e instalar Cisco IOL
```bash
# Buscar imagens Cisco IOL
pmg search iol vios

# Instalar Cisco vIOS (supondo ID 3)
pmg pull iol 3
```

### Exemplo 3: Verificar conectividade
```bash
# Antes de baixar, verifique a conexão
pmg test

# Se tudo estiver OK, prossiga com o download
pmg pull qemu 20
```

## 📁 Estrutura de Diretórios

```
/opt/pmg/               # Diretório principal do PMG
├── pmg.conf            # Arquivo de configuração
├── pmg.log             # Arquivo de logs
├── labhub.json         # Índice JSON das imagens
└── tmp/                # Arquivos temporários
```

## 🛠️ Configuração

O arquivo de configuração está localizado em `/opt/pmg/pmg.conf`:

```bash
USE_ARIA2C=false        # Usar aria2c para downloads mais rápidos
SSL_CHECK=true          # Verificar certificados SSL
CHANNEL=main            # Canal de atualização
```

## 🔌 Endpoints da API

PMG usa os seguintes endpoints do LabHub:

- **API Principal**: `https://labhub.eu.org/0:/addons/`
- **Índice JSON**: `https://labhub.eu.org/0:/addons/.lab-index.json`
- **Download de imagens**: `https://labhub.eu.org/0:/addons/{TYPE}/{IMAGE_NAME}`

## 🐛 Resolução de Problemas

### Problema: Erro ao baixar imagens
**Solução**: Verifique sua conectividade
```bash
pmg test
```

### Problema: Arquivo já existe
**Solução**: Use a flag --overwrite
```bash
pmg pull qemu 1 --overwrite
```

### Problema: Permissões negadas
**Solução**: Execute como root
```bash
sudo pmg search qemu
```

### Problema: API não responde
**Solução**: 
1. Verifique sua conexão com a internet
2. Teste os endpoints:
```bash
ping labhub.eu.org
curl -I https://labhub.eu.org/0:/addons/
```

## 📝 Logs

Os logs são armazenados em `/opt/pmg/pmg.log`. Para visualizar:

```bash
# Ver últimas 50 linhas
tail -n 50 /opt/pmg/pmg.log

# Ver logs em tempo real
tail -f /opt/pmg/pmg.log
```

## 🗑️ Desinstalação

### Método 1: Script automático
```bash
bash <(curl -sL https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/uninstall-pmg.sh)
```

### Método 2: Manual
```bash
# Remover binário
rm /usr/sbin/pmg

# Remover diretório (opcional, contém logs e configs)
rm -rf /opt/pmg
```

## 🆚 Diferenças do ishare2-cli

| Recurso | ishare2-cli | PMG v3.2 |
|---------|-------------|----------|
| URL Base | `drive.labhub.eu.org/0:/addons/.org` | `labhub.eu.org/0:/addons/` ✅ |
| API Endpoints | Antigas | Corrigidas ✅ |
| Nome do comando | `ishare2` | `pmg` |
| Diretório config | `/opt/ishare2/` | `/opt/pmg/` |
| Foco | Multi-funcional | Otimizado para downloads |

## 📊 Requisitos do Sistema

- Ubuntu/Debian Linux
- PNETLab (recomendado)
- Acesso root ou sudo
- Conexão com internet
- Pacotes: curl, wget, jq, unzip, unrar

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/NovaFuncionalidade`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/NovaFuncionalidade`)
5. Abra um Pull Request

## 📜 Licença

Este projeto é baseado no ishare2-cli e mantém a mesma licença GPL-3.0.

## 👥 Créditos

- **Projeto Original**: [ishare2-cli](https://github.com/ishare2-org/ishare2-cli) por @mativ00 & @sudoalx
- **Modificações**: Revoltado-RvT
- **API**: LabHub (labhub.eu.org)

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/Revoltado-RvT/PMG_V2/issues)
- **Telegram**: [@NetLabHub](https://t.me/NetLabHub)

## 🔄 Changelog

### v3.2 (Atual)
- ✅ URLs da API corrigidas para `labhub.eu.org`
- ✅ Código otimizado e limpo
- ✅ Logs melhorados
- ✅ Instalação simplificada
- ✅ Documentação completa

### v3.1
- Versão anterior com URLs incorretas

## ⚠️ Avisos Importantes

1. **Conexão**: Certifique-se de ter uma conexão estável com a internet
2. **Espaço**: Verifique se há espaço suficiente em disco antes de baixar imagens
3. **Permissões**: Execute sempre como root ou com sudo
4. **Backups**: Faça backup de suas configurações antes de atualizar

## 🌟 Features Futuras

- [ ] Suporte a múltiplos mirrors
- [ ] Download de múltiplas imagens simultaneamente
- [ ] Interface GUI web
- [ ] Verificação de integridade de arquivos (MD5/SHA1)
- [ ] Atualização automática
- [ ] Suporte a Docker images

---

**Nota**: Este projeto é uma ferramenta gratuita e open-source. Nunca pague por ela!
