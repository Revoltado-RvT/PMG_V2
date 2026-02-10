# 🗄️ PMG v3.2 - Integração MySQL

## 📋 Sobre a Integração MySQL

Esta versão do PMG inclui integração completa com MySQL para rastreamento de downloads, estatísticas de uso e análise de dados.

## 🔧 Configuração MySQL

### Credenciais Configuradas:
```bash
MYSQL_SOCKET="/media/2d05/revoltado/private/mysql/socket"
MYSQL_USER="root"
MYSQL_PASS="2n2Qkc7TtzLgOVxY"
MYSQL_DB="pmg_stats"
```

## 🚀 Instalação

### 1. Instalar a Versão MySQL:
```bash
# Baixar script com integração MySQL
wget -O /usr/sbin/pmg https://raw.githubusercontent.com/Revoltado-RvT/PMG_V2/main/pmg-mysql

# Tornar executável
chmod +x /usr/sbin/pmg
```

### 2. Inicializar Banco de Dados:
```bash
# Criar banco de dados e tabelas
pmg initdb
```

**Saída esperada:**
```
[+] Initializing MySQL database...
[✓] MySQL database initialized successfully
```

## 📊 Estrutura do Banco de Dados

### Tabela: `downloads`
Rastreia todos os downloads realizados:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT | ID único do download |
| image_type | VARCHAR(50) | Tipo da imagem (QEMU, IOL, DYNAMIPS) |
| image_id | INT | ID da imagem no índice |
| image_name | VARCHAR(255) | Nome da imagem |
| image_size | VARCHAR(50) | Tamanho da imagem |
| download_date | DATETIME | Data/hora do download |
| download_status | ENUM | Status: success, failed, in_progress |
| download_time_seconds | INT | Tempo de download em segundos |
| error_message | TEXT | Mensagem de erro (se houver) |

### Tabela: `searches`
Rastreia todas as buscas realizadas:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT | ID único da busca |
| search_type | VARCHAR(50) | Tipo de busca (QEMU, IOL, etc) |
| search_filter | VARCHAR(255) | Filtro aplicado |
| results_count | INT | Número de resultados |
| search_date | DATETIME | Data/hora da busca |

### Tabela: `usage_stats`
Rastreia ações gerais do usuário:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | INT | ID único da ação |
| action | VARCHAR(100) | Ação realizada |
| details | TEXT | Detalhes da ação |
| execution_date | DATETIME | Data/hora da execução |

## 📈 Comandos de Estatísticas

### Ver Estatísticas Completas:
```bash
pmg stats
```

**Exemplo de saída:**
```
=== PMG Statistics ===

📊 Download Statistics:
+---------+-------+--------------+
| Status  | Count | Avg Time (s) |
+---------+-------+--------------+
| success |    15 |        45.23 |
| failed  |     2 |        12.50 |
+---------+-------+--------------+

📦 Downloads by Type:
+----------+-----------+------------+
| Type     | Downloads | Successful |
+----------+-----------+------------+
| QEMU     |        10 |          9 |
| IOL      |         5 |          5 |
| DYNAMIPS |         2 |          1 |
+----------+-----------+------------+

📥 Recent Downloads (Last 10):
+------------------+------+------------------+---------+
| Date             | Type | Image            | Status  |
+------------------+------+------------------+---------+
| 2025-01-10 14:30 | QEMU | win10-2024.qcow2 | success |
| 2025-01-10 13:15 | IOL  | vios-15.6.bin    | success |
| 2025-01-10 12:00 | QEMU | ubuntu-22.04     | failed  |
+------------------+------+------------------+---------+

🔍 Search Statistics:
+----------+----------+-------------+
| Type     | Searches | Avg Results |
+----------+----------+-------------+
| QEMU     |       25 |          12 |
| IOL      |       10 |           8 |
| ALL      |        5 |          30 |
+----------+----------+-------------+
```

### Exportar Estatísticas para CSV:
```bash
# Exportar para arquivo padrão
pmg export

# Exportar para arquivo específico
pmg export /root/stats_backup.csv
```

**Saída:**
```
[+] Exporting statistics to: /tmp/pmg_stats_20250110_143000.csv
[✓] Statistics exported to: /tmp/pmg_stats_20250110_143000.csv
```

## 🔍 Consultas SQL Personalizadas

### Conectar ao MySQL:
```bash
mysql --socket=/media/2d05/revoltado/private/mysql/socket -uroot -p2n2Qkc7TtzLgOVxY -Dpmg_stats
```

### Exemplos de Consultas:

#### 1. Downloads nas últimas 24 horas:
```sql
SELECT 
    image_name,
    image_type,
    download_status,
    download_time_seconds,
    download_date
FROM downloads
WHERE download_date >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
ORDER BY download_date DESC;
```

#### 2. Imagens mais baixadas:
```sql
SELECT 
    image_name,
    image_type,
    COUNT(*) as total_downloads,
    SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) as successful,
    ROUND(AVG(download_time_seconds), 2) as avg_time
FROM downloads
GROUP BY image_name, image_type
ORDER BY total_downloads DESC
LIMIT 10;
```

#### 3. Taxa de sucesso por tipo:
```sql
SELECT 
    image_type,
    COUNT(*) as total_attempts,
    SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) as successful,
    ROUND(SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate
FROM downloads
GROUP BY image_type;
```

#### 4. Termos de busca mais populares:
```sql
SELECT 
    search_filter,
    COUNT(*) as search_count,
    ROUND(AVG(results_count), 0) as avg_results
FROM searches
WHERE search_filter IS NOT NULL AND search_filter != ''
GROUP BY search_filter
ORDER BY search_count DESC
LIMIT 10;
```

#### 5. Atividade por dia da semana:
```sql
SELECT 
    DAYNAME(download_date) as day_of_week,
    COUNT(*) as downloads,
    SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) as successful
FROM downloads
GROUP BY DAYNAME(download_date), DAYOFWEEK(download_date)
ORDER BY DAYOFWEEK(download_date);
```

#### 6. Tempo médio de download por tamanho:
```sql
SELECT 
    image_size,
    COUNT(*) as downloads,
    ROUND(AVG(download_time_seconds), 2) as avg_seconds,
    ROUND(AVG(download_time_seconds) / 60, 2) as avg_minutes
FROM downloads
WHERE download_status = 'success'
GROUP BY image_size
ORDER BY avg_seconds DESC;
```

## 📊 Dashboards e Visualizações

### Criar View para Dashboard:
```sql
CREATE VIEW download_summary AS
SELECT 
    DATE(download_date) as date,
    image_type,
    COUNT(*) as total_downloads,
    SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) as successful,
    SUM(CASE WHEN download_status = 'failed' THEN 1 ELSE 0 END) as failed,
    ROUND(AVG(download_time_seconds), 2) as avg_download_time
FROM downloads
GROUP BY DATE(download_date), image_type
ORDER BY date DESC, image_type;
```

### Consultar Dashboard:
```sql
SELECT * FROM download_summary WHERE date >= CURDATE() - INTERVAL 7 DAY;
```

## 🔧 Manutenção do Banco de Dados

### Limpar Dados Antigos (mais de 90 dias):
```sql
DELETE FROM downloads WHERE download_date < DATE_SUB(NOW(), INTERVAL 90 DAY);
DELETE FROM searches WHERE search_date < DATE_SUB(NOW(), INTERVAL 90 DAY);
DELETE FROM usage_stats WHERE execution_date < DATE_SUB(NOW(), INTERVAL 90 DAY);
```

### Otimizar Tabelas:
```sql
OPTIMIZE TABLE downloads;
OPTIMIZE TABLE searches;
OPTIMIZE TABLE usage_stats;
```

### Backup do Banco:
```bash
mysqldump --socket=/media/2d05/revoltado/private/mysql/socket -uroot -p2n2Qkc7TtzLgOVxY pmg_stats > /backup/pmg_stats_$(date +%Y%m%d).sql
```

### Restaurar Backup:
```bash
mysql --socket=/media/2d05/revoltado/private/mysql/socket -uroot -p2n2Qkc7TtzLgOVxY pmg_stats < /backup/pmg_stats_20250110.sql
```

## 🎯 Casos de Uso

### 1. Monitorar Downloads Falhados:
```bash
# Ver downloads com falha
mysql --socket=/media/2d05/revoltado/private/mysql/socket -uroot -p2n2Qkc7TtzLgOVxY -Dpmg_stats -e "
SELECT 
    download_date,
    image_name,
    error_message
FROM downloads 
WHERE download_status = 'failed'
ORDER BY download_date DESC
LIMIT 10;"
```

### 2. Relatório Mensal:
```bash
# Exportar relatório do mês atual
pmg export /reports/pmg_$(date +%Y%m).csv
```

### 3. Análise de Performance:
```sql
-- Downloads mais lentos
SELECT 
    image_name,
    image_size,
    download_time_seconds,
    ROUND(download_time_seconds / 60, 2) as minutes
FROM downloads
WHERE download_status = 'success'
ORDER BY download_time_seconds DESC
LIMIT 20;
```

## 🚨 Troubleshooting

### Problema: MySQL não conecta
```bash
# Verificar socket
ls -la /media/2d05/revoltado/private/mysql/socket

# Testar conexão
mysql --socket=/media/2d05/revoltado/private/mysql/socket -uroot -p2n2Qkc7TtzLgOVxY -e "SELECT 1;"
```

### Problema: Tabelas não criadas
```bash
# Reinicializar banco
pmg initdb
```

### Problema: Permissões negadas
```sql
-- Verificar permissões
SHOW GRANTS FOR 'root'@'localhost';

-- Conceder permissões se necessário
GRANT ALL PRIVILEGES ON pmg_stats.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
```

## 📈 Métricas Úteis

### KPIs Principais:
- **Taxa de Sucesso**: % de downloads bem-sucedidos
- **Tempo Médio de Download**: Tempo médio por tipo de imagem
- **Popularidade de Imagens**: Imagens mais baixadas
- **Horários de Pico**: Quando mais downloads ocorrem
- **Eficiência de Buscas**: Quantas buscas resultam em downloads

### Queries para KPIs:
```sql
-- Taxa de sucesso global
SELECT 
    ROUND(SUM(CASE WHEN download_status = 'success' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as success_rate_percent
FROM downloads;

-- Horários de pico
SELECT 
    HOUR(download_date) as hour,
    COUNT(*) as downloads
FROM downloads
GROUP BY HOUR(download_date)
ORDER BY downloads DESC;

-- Conversão busca -> download
SELECT 
    (SELECT COUNT(*) FROM downloads) as total_downloads,
    (SELECT COUNT(*) FROM searches) as total_searches,
    ROUND((SELECT COUNT(*) FROM downloads) * 100.0 / (SELECT COUNT(*) FROM searches), 2) as conversion_rate
FROM DUAL;
```

## 🔐 Segurança

### Alterar Senha MySQL (se necessário):
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'nova_senha_aqui';
FLUSH PRIVILEGES;
```

Depois atualizar o script PMG com a nova senha.

## 📞 Suporte

Para problemas com a integração MySQL:
1. Verificar logs: `tail -f /opt/pmg/pmg.log`
2. Testar conexão MySQL manualmente
3. Verificar permissões do socket
4. Reportar issue: [GitHub Issues](https://github.com/Revoltado-RvT/PMG_V2/issues)

---

**Versão**: 3.2-mysql  
**Última atualização**: 2025-01-10
