---
title: "Sistema de Logs"
description: "Sistema de logs do cliente VPN IPsec - arquivo único e filtros inteligentes"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [uso, logging, logs, debug]
aliases: [Logging, Logs, Sistema de Logs]
related:
  - README
  - uso/Connecting
  - uso/Configuration
  - componentes/AppLoggers
  - componentes/StatusLogWidget
  - componentes/MainWindow
---

# 📝 Sistema de Logs

## Visão Geral

O sistema de logs registra eventos de conexão e atividades do usuário.

## Arquivos de Log

| Arquivo | Localização | Descrição |
|---------|------------|-----------|
| Log de conexão | `~/.vpnlogs/vpn_ipsec_client.log` | Log completo da sessão |
| Log de depuração | `debug.log` (quando usado) | Log detalhado para desenvolvimento |

## Comportamento de Logging

### Design Intencional
- **Logs salvos apenas quando conectado**: Evita excesso de logs e protege dados sensíveis
- **Display na UI sempre ativo**: Mostra eventos mesmo sem conexão
- **Arquivo único**: Todas as sessões registradas no mesmo arquivo (`vpn_ipsec_client.log`)

### Ciclo de Vida da Sessão

```
┌─────────────────────────────────────────────┐
│              INÍCIO DA CONEXÃO              │
├─────────────────────────────────────────────┤
│  ============ INICIO DO LOG ============    │
│  VPN IPsec Log - Connection: minha-vpn      │
│  Start Time: 2026-08-03 10:30:00            │
│  ========================================   │
│  [10:30:01] Status: Conectado               │
│  [10:30:05] Conectado a minha-vpn.          │
│  ...                                        │
│  ============ FIM DO LOG ============       │
│  End Time: 2026-08-03 10:35:00              │
│  Connection ended.                          │
│  ========================================   │
└─────────────────────────────────────────────┘
```

## Visualização

### Na Interface
- Área de logs na parte inferior da janela
- Mensagens com timestamp
- Botão "Limpar Logs" para limpar display
- Status de conexão em tempo real

### No Arquivo
```bash
# Ver últimas linhas
tail -f ~/.vpnlogs/vpn_ipsec_client.log

# Filtrar por conexão
grep "minha-vpn" ~/.vpnlogs/vpn_ipsec_client.log

# Ver apenas erros
grep -i "erro\|fail" ~/.vpnlogs/vpn_ipsec_client.log
```

## Componentes de Log

| Componente | Responsabilidade |
|------------|-----------------|
| `AppLoggers` | Gerencia arquivo e formatação |
| `StatusLogWidget` | Display na interface |
| `MainWindow` | Orquestra adição de mensagens |

## Formato de Mensagens

### Padrão
```
[YYYY-MM-DD HH:MM:SS] mensagem
```

### Mensagens com timestamp duplicado
```python
# Se a mensagem já contém timestamp, não adiciona outro
if message.startswith('[') and ']' in message[:20]:
    formatted_message = f"{message}"
else:
    formatted_message = f"[{timestamp}] {message}"
```

## Boas Práticas de Debug

### Log detalhado para desenvolvimento
```bash
python -u main.py 2>&1 | tee debug.log
```

### Monitorar em tempo real
```bash
tail -f ~/.vpnlogs/vpn_ipsec_client.log
```

### Verificação de permissões
```bash
ls -la ~/.vpnlogs/
# Deve mostrar permissões 755 no diretório
```

## Configuração

Não há configuração manual necessária - o diretório é criado automaticamente:

```python
LOGS_DIR = os.path.expanduser("~/.vpnlogs")
os.makedirs(LOGS_DIR, mode=0o755, exist_ok=True)
LOG_FILE_PATH = os.path.join(LOGS_DIR, "vpn_ipsec_client.log")
```

---
*[[README|← Voltar]] | [[uso/Connecting|Conectando]] | [[uso/Configuration|Configuração]]*