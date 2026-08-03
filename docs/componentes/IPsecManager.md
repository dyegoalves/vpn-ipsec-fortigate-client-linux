---
title: "IPsecManager"
description: "Facade para operações IPsec - orquestra parser e commander"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ipsec, manager, business-logic]
aliases: [IPsecManager, GerenciadorIPsec]
related:
  - README
  - arquitetura/Components
  - componentes/IPsecCommander
  - componentes/IPsecConfigParser
  - componentes/AppConfig
---

# ⚙️ IPsecManager

**Arquivo:** `src/ipsec/ipsec_manager.py`

## Responsabilidades

- **Facade** para operações IPsec
- Carrega conexões disponíveis
- Gerencia o ciclo de vida da conexão VPN
- Coordena entre `IPsecConfigParser` e `IPsecCommander`

## Métodos Principais

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `__init__()` | - | Inicializa parser, commander, carrega conexões |
| `load_connections()` | `List[str]` | Descobre conexões IPsec configuradas |
| `get_connection_details(conn_name)` | `Tuple[str, str, dict]` | Retorna caminho, IP do servidor, detalhes |
| `connect_connection(conn_name)` | `Tuple[bool, str]` | Inicia conexão |
| `disconnect_connection(conn_name)` | `Tuple[bool, str]` | Termina conexão |
| `get_connection_status(conn_name)` | `Tuple[str, bool]` | Status: (texto, conectado?) |

## Fluxo de Conexão

```
MainWindow.connect_vpn()
  └─ IPsecManager.connect_connection()
       └─ IPsecCommander.connect_connection()
            └─ subprocess: sudo ipsec up <conn>
```

## Fluxo de Status

```
MainWindow (timer: 5s)
  └─ IPsecManager.get_connection_status()
       └─ IPsecCommander.get_connection_status()
            └─ subprocess: sudo ipsec status
            └─ Analisa output para: "Conectado", "Conectando", "Desconectado"
```

## Estado Interno

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `config_parser` | `IPsecConfigParser` | Parser de arquivos de config |
| `commander` | `IPsecCommander` | Executor de comandos |
| `connections` | `List[str]` | Lista de nomes de conexões |
| `current_connection` | `str` | Conexão atualmente selecionada |

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*