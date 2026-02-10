# 🚀 PNETLab Manager v3.0 - Quick Start Guide

**Da instalação ao primeiro lab em 5 minutos!**

---

## 📦 Instalação (30 segundos)

```bash
# Um único comando para instalar tudo
wget -qO- https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/auto-install-pmg.sh | bash

# Recarregar shell
source ~/.bashrc
```

✅ **Pronto!** O PMG está instalado.

---

## ⚙️ Configuração Inicial (1 minuto)

```bash
pmg configure
```

Você será perguntado:

```
[?] IP/Hostname do PNETLab: 192.168.1.100
[?] Porta SSH: 22
[?] Usuário: root
[?] Senha: sua_senha
[?] Diretório de downloads: ~/pmg-downloads
```

✅ **Configurado!**

---

## 🔍 Primeira Busca (30 segundos)

```bash
# Buscar imagens Fortinet
pmg search fortinet
```

**Resultado:**
```
 Searching across all types for "fortinet"
=================================================
ID   NAME                              TYPE  SIZE
--   ----                              ----  ----
481  fortinet-5.2                      qemu  33.2 MB
482  fortinet-FAC-v6-build0420         qemu  87.9 MB
483  fortinet-FAC-v6.6.2-build1669     qemu  126.2 MB
...

[✓] Encontradas 12 imagens
```

✅ **Imagens encontradas!**

---

## 📥 Primeiro Download (2 minutos)

### Opção 1: Download por ID

```bash
# Usar o ID da busca anterior
pmg pull 481
```

### Opção 2: Download Direto

```bash
# Download direto por nome
pmg download qemu fortinet-5.2
```

**Progresso:**
```
[INFO] Baixando: fortinet-5.2.vmdk
[████████████████████] 100% | 33.2 MB | 2.5 MB/s | ETA: 0s
[✓] Download concluído!
```

✅ **Imagem baixada!**

---

## 🔄 Conversão Automática (30 segundos)

```bash
# Converter para QCOW2 (formato do PNETLab/EVE-NG)
pmg convert ~/pmg-downloads/qemu/fortinet-5.2.vmdk qcow2
```

**Ou deixar o PMG fazer tudo automaticamente:**

```bash
# Download + Conversão + Upload (tudo em um comando)
pmg install qemu fortinet-5.2
```

✅ **Imagem convertida!**

---

## 📤 Upload para Servidor (1 minuto)

```bash
# Upload manual
pmg upload qemu fortinet-5.2.qcow2
```

**Progresso:**
```
[INFO] Uploading: fortinet-5.2.qcow2
[████████████████████] 100% | 33.2 MB
[INFO] Corrigindo permissões...
[✓] Upload concluído!
```

✅ **Imagem no servidor!**

---

## 🎯 Workflow Completo (All-in-One)

O jeito mais fácil: **deixar o PMG fazer tudo**

```bash
# 1. Buscar
pmg search fortinet

# 2. Instalar (download + conversão + upload automático)
pmg install qemu fortinet-5.2

# Ou usar o ID da busca
pmg install 481
```

**Isso vai:**
1. ✅ Baixar a imagem
2. ✅ Converter para QCOW2
3. ✅ Fazer upload para o servidor
4. ✅ Corrigir permissões

**Tudo automaticamente!** ☕

---

## 📋 Comandos Essenciais

### Busca

```bash
pmg search fortinet          # Buscar Fortinet
pmg search cisco iol         # Buscar Cisco IOL
pmg search juniper qemu      # Buscar Juniper QEMU
pmg list                     # Listar TUDO
```

### Download

```bash
pmg pull 481                 # Por ID
pmg download qemu fortinet-5.2  # Por nome
```

### Conversão

```bash
pmg convert arquivo.vmdk qcow2   # VMware → QCOW2
pmg convert arquivo.vdi qcow2    # VirtualBox → QCOW2
```

### Upload

```bash
pmg upload qemu arquivo.qcow2    # Upload QEMU
pmg upload iol arquivo.bin       # Upload IOL
```

### Instalação Completa

```bash
pmg install qemu fortinet-5.2    # All-in-one
pmg install 481                  # Por ID
```

### Utilitários

```bash
pmg test                     # Testar conexão
pmg installed                # Ver imagens instaladas
pmg help                     # Ajuda completa
pmg version                  # Ver versão
```

---

## 🔧 Troubleshooting Rápido

### Busca não funciona?

```bash
pmg cache-update
```

### Download falha?

```bash
pmg test
```

### Upload falha?

```bash
# Testar SSH manualmente
ssh root@IP_DO_SERVIDOR

# Reconfigurar
pmg configure
```

### Comando não encontrado?

```bash
source ~/.bashrc
# ou
export PATH="$PATH:$HOME/.local/bin"
```

---

## 🏆 Casos de Uso Comuns

### Caso 1: Lab Fortinet Básico

```bash
pmg search fortinet
pmg install qemu fortinet-5.2
```

**Tempo total: ~3 minutos** ⏱️

---

### Caso 2: Lab Multi-Vendor

```bash
# Cisco
pmg install iol cisco-iol-1563
# Fortinet
pmg install qemu fortinet-5.2
# Juniper
pmg install qemu juniper-vmx-20.2
```

**Tempo total: ~10 minutos** ⏱️

---

### Caso 3: Converter Imagem Própria

```bash
# Você tem uma imagem VMware
pmg convert ~/Downloads/FortiGate.vmdk qcow2
pmg upload qemu FortiGate.qcow2
```

**Tempo total: ~2 minutos** ⏱️

---

## 🎓 Próximos Passos

### Documentação Completa

- **[INSTALL.md](INSTALL.md)** - Guia detalhado de instalação
- **[README.md](README.md)** - Documentação completa
- **[EXEMPLOS_PRATICOS_v3.md](EXEMPLOS_PRATICOS_v3.md)** - 20+ exemplos práticos

### Recursos Online

- **LabHub QEMU**: https://labhub.eu.org/0:/addons/qemu/
- **LabHub IOL**: https://labhub.eu.org/0:/addons/iol/
- **GitHub**: https://github.com/Revoltado-RvT/PMG_V2

---

## 💡 Dicas Pro

### 1. Use Aliases

Adicione ao seu `~/.bashrc`:

```bash
alias pms='pmg search'
alias pmd='pmg download'
alias pmi='pmg install'
alias pml='pmg list'
```

### 2. Cache Inteligente

O PMG mantém cache por 24h. Para forçar atualização:

```bash
pmg cache-update
```

### 3. Modo Debug

Para ver o que está acontecendo:

```bash
DEBUG=1 pmg search fortinet
```

### 4. Downloads em Lote

```bash
# Baixar múltiplas imagens
for id in 481 482 483; do
    pmg pull $id
done
```

### 5. Backup de Configuração

```bash
# Backup
cp ~/.pmg/config.conf ~/.pmg/config.backup

# Restaurar
cp ~/.pmg/config.backup ~/.pmg/config.conf
```

---

## 🎯 Checklist de Sucesso

Após seguir este guia, você deve ter:

- ✅ PMG instalado e funcionando
- ✅ Servidor configurado
- ✅ Primeira imagem baixada
- ✅ Imagem convertida e no servidor
- ✅ Lab funcionando

**Parabéns! 🎉** Você está pronto para criar labs incríveis!

---

## 📞 Ajuda

Problemas? 

1. Execute `pmg test` para diagnóstico
2. Consulte `pmg help` para comandos
3. Veja [INSTALL.md](INSTALL.md) para troubleshooting
4. Abra issue no [GitHub](https://github.com/Revoltado-RvT/PMG_V2/issues)

---

<div align="center">

**⏱️ Do zero ao lab funcionando: ~5 minutos**

**Made with ❤️ for Network Engineers**

[⬅️ Voltar](README.md) | [Instalação Detalhada](INSTALL.md) | [Exemplos](EXEMPLOS_PRATICOS_v3.md)

</div>
