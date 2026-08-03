---
title: "Arquitetura"
description: "Referência técnica de módulos e estrutura do código"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [arquitetura, modulos, codigo, referencia]
aliases: [Modulos, Modules]
related:
  - README
  - arquitetura/Overview
  - arquitetura/Components
  - desenvolvimento/Code-Structure
---

# 📋 Referência de Módulos

## src/config/app_config.py

Centraliza configuração, constantes e detecção de ambiente.

| Item | Descrição |
|------|-----------|
| `APP_TITLE`, `WINDOW_SIZE` | Metadados da aplicação |
| `CONNECTION_STATES` | Dicionário de estados de conexão → strings de exibição |
| `DEFAULT_MESSAGES` | Mensagens padrão da aplicação |
| `IPSEC_BIN` | Binário IPsec detectado |
| `SWANCTL_BIN` | Binário swanctl detectado (strongSwan 6+) |
| `USE_SWANCTL` | Flag booleana: usa swanctl (true) ou ipsec legado (false) |
| `IPSEC_CONFIG_PATHS` | Caminhos de configuração (override via `VPN_IPSEC_CONF`) |
| `IPSEC_D_PATH` | Diretório de configs IPsec (override via `VPN_IPSEC_D_PATH`) |
| `LOGS_DIR`, `LOG_FILE_PATH` | Local do arquivo de log |

## src/ipsec/

### ipsec_config_parser.py

Classe `IPsecConfigParser`: lê e interpreta arquivos de configuração IPsec.

- `_get_all_config_files()`: coleta todos os arquivos de config relevantes
- `_connection_exists_in_file()`: verifica se conexão existe (formatos legado e swanctl)
- `_parse_connections_from_file()`: extrai nomes de conexão do conteúdo
- `find_connection_file()`: localiza arquivo contendo determinada conexão
- `get_connection_details_from_file()`: parseia parâmetros detalhados da conexão
- `get_server_address_from_details()`: extrai endereço do servidor

### ipsec_commander.py

Classe `IPsecCommander`: executa comandos IPsec de baixo nível e interpreta output.

- `connect_connection()`: inicia conexão (swanctl ou ipsec)
- `disconnect_connection()`: termina conexão
- `get_connection_status()`: obtém status de conexão específica
- `_extract_connection_section()`: parseia seção de output do comando
- `_is_sudo_error()`: detecta erros de permissão sudo
- `_is_connection_configured()`: verifica se conexão existe nos configs

### ipsec_manager.py

Classe `IPsecManager`: orquestra operações, combinando parser e commander (Facade).

- `__init__()`: inicializa parser e commander, carrega conexões
- `load_connections()`: descobre conexões IPsec disponíveis
- `get_connection_details()`: retorna detalhes completos de conexão
- `connect_connection()`: wrapper do connect do commander
- `disconnect_connection()`: wrapper do disconnect do commander
- `get_connection_status()`: wrapper do status do commander

## src/loggers/app_loggers.py

Classe `AppLoggers`: gerencia logging centralizado.

- `set_connection_status()`: rastreia estado da conexão
- `create_log_file()`: adiciona entrada de início de conexão ao log
- `delete_log_file()`: adiciona entrada de fim de conexão ao log
- `_write_to_log_file()`: escrita de baixo nível
- `add_log_message()`: adiciona mensagem com timestamp
- `get_log_file_path()`: retorna caminho do log

## src/ui/

### main_window.py

Classe `MainWindow` (QMainWindow): janela principal e controller.

- `load_ipsec_config()`: carrega conexões do IPsecManager
- `on_connection_changed()`: trata mudança de seleção
- `refresh_connection_status()`: atualiza status periodicamente (timer 5s)
- `toggle_connection()`: trata eventos do toggle switch
- `connect_vpn()` / `disconnect_vpn()`: executa ações de conexão
- `add_status_message()`: adiciona mensagens à UI e ao log
- `update_theme()`, `handle_theme_change()`, `apply_theme()`: gerenciamento de tema
- `closeEvent()`: encerramento da aplicação

### connection_config_widget.py

Classe `ConnectionConfigWidget` (QGroupBox): exibe detalhes da conexão e controla toggle.

Signals:
- `connection_changed`: mudança de seleção
- `toggle_requested`: mudança de estado do toggle

Métodos:
- `update_connection_details()`: popula formulário
- `set_connections()`: popula dropdown
- `get_selected_connection()`: conexão selecionada
- `update_status()`: atualiza label de status e toggle
- `set_error_state()`: mostra estado de erro

### status_log_widget.py

Classe `StatusLogWidget` (QWidget): exibe status e logs em área somente-leitura.

Signals:
- `clear_logs_requested`: clique no botão limpar

Métodos:
- `add_message()`: adiciona mensagem (filtra mensagens rotineiras)
- `_is_routine_status_message()`: filtra mensagens repetitivas
- `clear_display()`: limpa display

### toggle_switch_button.py

Classe `ToggleSwitchButton` (QWidget): toggle animado com 3 estados.

Signals:
- `stateChanged`: mudança de estado

Métodos:
- `setConnectionState()`: define estado visual (CONNECTED/DISCONNECTED/CONNECTING)
- `isChecked()`: estado atual

### theme_selector.py

Classe `ThemeSelectorWidget` (QWidget): dropdown Auto/Dark/Light.

Signals:
- `theme_changed`: mudança de tema

## src/utils/system_theme.py

Função `get_system_color_scheme()`: detecta esquema de cores do sistema (Dark/Light) via gdbus.
