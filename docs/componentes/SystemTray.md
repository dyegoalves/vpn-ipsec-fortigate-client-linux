---
title: "SystemTray"
description: "Ícone de bandeja do sistema com status da conexão VPN"
date: 2026-08-18T13:48:02-03:00
updated: 2026-08-18T13:48:02-03:00
tags: [componentes, ui, systemtray, tray, bandeja]
aliases: [SystemTray, Bandeja]
related:
  - README
  - componentes/MainWindow
  - uso/Connecting
---

# 🖥️ SystemTray

**Arquivo:** `src/ui/system_tray.py`

## Responsabilidades

- Ícone persistente na bandeja do sistema
- Menu de contexto com ações de conectar/desconectar
- Atualização do ícone conforme status da conexão
- Notificações de mudança de estado

## Funcionalidades-Chave

### Ícone Dinâmico por Status
- **Conectado**: `src/assets/vpn-green.png`
- **Desconectado/Erro**: `src/assets/vpn-red.png`
- **Outros status**: ícone padrão azul (`src/assets/icon.svg`)

### Sinais

- `connection_selected(str)` - Conexão selecionada no menu
- `connect_requested()` - Solicitação de conexão
- `disconnect_requested()` - Solicitação de desconexão
- `quit_requested()` - Solicitação de saída
- `window_shown()` - Janela deve ser exibida
- `window_hidden()` - Janela deve ser ocultada

## Integração com Outros Componentes

- `MainWindow` → controla conexão/desconexão e exibe/oculta janela
- `TrayIconProvider` → fornece ícones renderizados para a bandeja
- `IPsecManager` → consulta status atual da conexão

## Uso

```python
from src.ui.system_tray import SystemTray

tray = SystemTray(parent)
tray.update_status("Conectado", is_connected=True)
tray.set_connections(["vpn-fortigate"], current="vpn-fortigate")
```

## Comportamento do Menu

- **Mostrar Janela** - Alterna visibilidade da janela principal
- **Conexão** - Lista de conexões configuradas
- **Conectar** - Inicia conexão VPN
- **Desconectar** - Termina conexão VPN
- **Sair** - Fecha aplicação

## Notificações

Exibe notificações nativas do sistema quando:
- Conexão é estabelecida
- Conexão é encerrada
- Erro ocorre durante conexão/desconexão

## Tooltip

Mostra formato:
```
Cliente VPN IPsec Fortigate
<nome-conexão>: <status>
```

---
*[[README|← Voltar]] | [[componentes/MainWindow|MainWindow]] | [[docs/README|Documentação]]*
