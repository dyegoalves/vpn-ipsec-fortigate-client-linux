---
title: "Componentes"
description: "Resumo de todos os componentes do cliente VPN IPsec"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, visao-geral, sistema]
aliases: [Componentes, ComponentesVisão]
related:
  - README
  - arquitetura/Overview
  - componentes/IPsecManager
---



# 🧩 Componentes

## Visão Geral

| Componente | Arquivo | Responsabilidade |
|------------|---------|-----------------|
| `MainWindow` | `src/ui/main_window.py` | Janela principal, coordenação geral |
| `ConnectionConfigWidget` | `src/ui/connection_config_widget.py` | Seleção/configuração de conexões |
| `StatusLogWidget` | `src/ui/status_log_widget.py` | Logs de conexão na UI |
| `ToggleSwitchButton` | `src/ui/toggle_switch_button.py` | Toggle visual conectar/desconectar |
| `ThemeSelectorWidget` | `src/ui/theme_selector.py` | Seleção de tema claro/escuro |
| `IPsecManager` | `src/ipsec/ipsec_manager.py` | Orquestra operações IPsec |
| `IPsecCommander` | `src/ipsec/ipsec_commander.py` | Executa comandos IPsec |
| `IPsecConfigParser` | `src/ipsec/ipsec_config_parser.py` | Lê/parseia configs IPsec |
| `AppLoggers` | `src/loggers/app_loggers.py` | Gerenciamento de logs |
| `AppConfig` | `src/config/app_config.py` | Configurações constantes |

## UI Components

### MainWindow
- Janela principal da aplicação
- Gerencia timers de status (5s) e tema (10s)
- Trata `closeEvent` para desconectar VPN
- Instância única via `QLocalSocket`

### ConnectionConfigWidget
- Combo box de seleção de conexão
- Labels de detalhes (servidor, auth, protocolos)
- Toggle switch de conexão
- Emite sinais: `connection_changed`, `toggle_requested`

## Business Logic

### IPsecManager
- Carrega conexões dos arquivos de config
- Obtém detalhes de conexão específica
- Encapsula `connect_connection`, `disconnect_connection`, `get_connection_status`
- Delega comando ao `IPsecCommander` e parsing ao `IPsecConfigParser`

## Service Layer

### IPsecCommander
- Executa comandos do sistema via `subprocess`
- Suporta duas interfaces:
  - `swanctl` (strongSwan 6+, vici protocol)
  - `ipsec` legado (stroke protocol)
- Interpreta saída para estados

### IPsecConfigParser
- Lê arquivos de config IPsec
- Formato legado: `conn NAME`
- Formato swanctl: `NAME { ... }`

## Configuration

### AppConfig
- Detecta binário IPsec (`strongswan` > `ipsec`)
- Detecta interface swanctl automaticamente
- Caminhos configuráveis via env vars

---
*[[README|← Voltar]]*