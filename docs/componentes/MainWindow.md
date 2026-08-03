---
title: "MainWindow"
description: "Janela principal e controller da aplicação"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ui, mainwindow, controller]
aliases: [MainWindow, JanelaPrincipal]
related:
  - README
  - arquitetura/Components
  - componentes/ConnectionConfigWidget
  - componentes/ThemeSelectorWidget
---

# 🖼️ MainWindow

**Arquivo:** `src/ui/main_window.py`

## Responsabilidades

- Janela principal da aplicação
- Controller que orquestra a UI e a lógica de negócio
- Gerenciamento de temas (claro/escuro)
- Singleton (previne múltiplas instâncias)
- Atualização periódica de status
- Gerenciamento do ciclo de vida da conexão VPN

## Funcionalidades-Chave

### Singleton via Socket Local
```python
socket_name = "vpn-ipsec-client-socket"
local_socket = QLocalSocket()
local_socket.connectToServer(socket_name)

if local_socket.waitForConnected(500):
    local_socket.write(b"FOCUS")
    local_socket.flush()
    sys.exit(0)
```

### Gerenciamento de Tema
- Detecta tema do sistema via `system_theme.get_system_color_scheme()`
- Aplica estilos QSS (dark_theme.qss/light_theme.qss)
- Timer para verificar mudanças no tema do sistema a cada 10s

### Timer de Atualização de Status
- Verifica status da conexão a cada 5 segundos
- Evita atualizações durante transições (CONNECTING/DISCONNECTING)

## Sinais Importantes

- **Nenhum** (classe principal que consome sinais de outros componentes)

## Integração com Outros Componentes

- `ConnectionConfigWidget` → sinais `connection_changed`, `toggle_requested`
- `ThemeSelectorWidget` → sinal `theme_changed`
- `StatusLogWidget` → sinal `clear_logs_requested`
- `IPsecManager` → instanciado como atributo `connection_manager`
- `AppLoggers` → instanciado como atributo `log_manager`

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]] | [[arquitetura/Overview|Arquitetura]]*