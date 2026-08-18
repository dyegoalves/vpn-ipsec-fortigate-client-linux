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

O menu de contexto é nativo do ambiente (Breeze no KDE Plasma), renderizado pelo desktop — não pelo Qt. Ícones do tema do sistema:

| Ação | Ícone (tema) | Comportamento |
|---|---|---|
| Mostrar Janela | `window-new` | Exibe a janela principal (botão, sem toggle) |
| *Conexões* | `network-vpn` | Lista conexões; clique seleciona |
| Conectar | `network-connect` | Inicia conexão VPN |
| Desconectar | `network-offline` | Termina conexão VPN |
| Sair | `application-exit` | Fecha aplicação |

Notas:
- **Mostrar Janela** não é checkable — é botão de ação simples (o checkbox foi removido)
- Ações de conexão **não** são checkable — a conexão ativa é refletida no tooltip e no ícone do tray, não via radio button no menu
- Ícones em todas as ações tornam a coluna de ícones uniforme (evita espaço vazio à esquerda em ações sem ícone)

## Comportamento dos Cliques no Ícone

| Ação | Comportamento |
|---|---|
| 1 clique esquerdo | Nada (registra o tempo para detecção de duplo clique) |
| 2 cliques esquerdo (≤ 300ms) | Abre a janela principal |
| 1 clique direito | Menu de contexto nativo |

> **Nota:** O sinal `DoubleClick` do `QSystemTrayIcon` não é suportado em implementações Linux com appindicator/StatusNotifierItem — o ambiente sempre emite `Trigger`. Por isso o duplo clique é detectado manualmente com `QElapsedTimer`: um 2º `Trigger` dentro de 300ms dispara a abertura da janela.

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
