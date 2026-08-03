---
title: "ConnectionConfigWidget"
description: "Widget de configuração e seleção de conexões IPsec"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ui, widget, conexao]
aliases: [ConnectionConfigWidget, WidgetConexao]
related:
  - README
  - arquitetura/Components
  - componentes/MainWindow
  - componentes/ToggleSwitchButton
---

# 🎛️ ConnectionConfigWidget

**Arquivo:** `src/ui/connection_config_widget.py`

## Responsabilidades

- Exibe seleção de conexão (dropdown)
- Mostra detalhes da conexão selecionada
- Controla toggle switch de conexão
- Emite sinais para mudança de seleção e toggle

## Sinais Emitidos

| Sinal | Parâmetro | Descrição |
|-------|-----------|-----------|
| `connection_changed` | `str` | Nome da conexão selecionada |
| `toggle_requested` | `bool` | Estado do toggle (True=ligar, False=desligar) |

## Interface

### Dropdown de Conexão
```python
self.conn_selector = QComboBox()
self.conn_selector.currentTextChanged.connect(self._on_connection_changed)
```

### Detalhes Exibidos
| Campo | Label | Fonte |
|-------|-------|-------|
| Nome da Conexão | `conn_name_label` | `conn_details["conn_name"]` |
| Endereço do Servidor | `server_address_label` | `conn_details["right"]` |
| Arquivo de Configuração | `config_file_label` | `config_file_path` |
| Tipo de Autenticação | `auth_type_label` | `authby` / `leftauth` / `rightauth` |
| Protocolos (IKE/ESP) | `protocols_label` | `ike`/`esp` |
| Sub-rede Remota | `rightsubnet_label` | `rightsubnet` |

### Toggle Switch
- Widget customizado: `ToggleSwitchButton`
- Estados: CONNECTED, DISCONNECTED, CONNECTING
- Cores: verde (conectado), vermelho (desconectado)

## Métodos Principais

| Método | Parâmetros | Descrição |
|--------|------------|-----------|
| `set_connections()` | `List[str]` | Popula dropdown |
| `get_selected_connection()` | - | Retorna texto do dropdown |
| `update_connection_details()` | `conn_name, file, server, details` | Atualiza labels |
| `update_status()` | `status, is_connected` | Atualiza status + toggle |
| `set_error_state()` | `message` | Mostra erro no dropdown |

## Lógica do Toggle

```python
def _on_toggle_state_changed(self, state):
    if not hasattr(self.toggle_switch, "_current_state") \
       or self.toggle_switch._current_state not in ["CONNECTING", "DISCONNECTING"]:
        self.toggle_requested.emit(state)
```

Evita emitir sinal durante transições de estado.

## Layout

- Grid layout com 3 colunas
- Coluna 0: Labels (stretch=1)
- Coluna 1: Valores (stretch=2)
- Coluna 2: Toggle (stretch=0)

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*