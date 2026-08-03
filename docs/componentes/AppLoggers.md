---
title: "AppLoggers"
description: "Gerenciamento de logs centralizado - arquivo único em ~/.vpnlogs/"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, logging, logs]
aliases: [AppLoggers, Logger]
related:
  - README
  - arquitetura/Components
  - componentes/AppConfig
  - uso/Logging
---

# 📝 AppLoggers

**Arquivo:** `src/loggers/app_loggers.py`

## Responsabilidades

- Gerencia logging centralizado
- Armazena logs em arquivo único (`~/.vpnlogs/vpn_ipsec_client.log`)
- Cria blocos de início e fim de conexão

## Arquivo de Log

| Campo | Localização | Descrição |
|-------|------------|-----------|
| Log de conexão | `~/.vpnlogs/vpn_ipsec_client.log` | Log completo da sessão |

## Ciclo de Vida da Sessão

```
┌─────────────────────────────────────────────┐
│              INÍCIO DA CONEXÃO              │
├─────────────────────────────────────────────┤
│  ============ INICIO DO LOG ============    │
│  VPN IPsec Log - Connection: minha-vpn      │
│  Start Time: 2026-08-03 10:30:00            │
│  ========================================   │
│  [10:30:01] Status: Conectado               │
│  ...                                        │
│  ============ FIM DO LOG ============       │
│  End Time: 2026-08-03 10:35:00              │
│  Connection ended.                          │
│  ========================================   │
└─────────────────────────────────────────────┘
```

## Métodos

| Método | Parâmetros | Descrição |
|--------|------------|-----------|
| `set_connection_status()` | `bool` | Define estado de conexão |
| `create_log_file()` | `str` | Cria cabeçalho da sessão |
| `delete_log_file()` | - | Adiciona rodapé da sessão |
| `_write_to_log_file()` | `str` | Escrita de baixo nível |
| `add_log_message()` | `str` | Adiciona mensagem com timestamp |
| `get_log_file_path()` | - | Retorna caminho do arquivo |

## Formato de Mensagens

### Padrão
```
YYYY-MM-DD HH:MM:SS] mensagem
```

## Boas Práticas

- Logs apenas quando conectado (design intencional)
- Timestamp automático em cada mensagem
- Diretório criado automaticamente

## Localização

```python
LOGS_DIR = os.path.expanduser("~/.vpnlogs")
LOG_FILE_PATH = os.path.join(LOGS_DIR, "vpn_ipsec_client.log")
```

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]] | [[uso/Logging|Sistema de Logs]]*