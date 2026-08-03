---
title: "ToggleSwitchButton"
description: "Widget de toggle switch customizado para conectar/desconectar"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ui, widget, toggle]
aliases: [ToggleSwitchButton, ToggleSwitch]
related:
  - README
  - arquitetura/Components
  - componentes/ConnectionConfigWidget
  - componentes/MainWindow
---

# 🔘 ToggleSwitchButton

**Arquivo:** `src/ui/toggle_switch_button.py`

## Responsabilidades

- Widget visual toggle customizado (ligado/desligado)
- Estado visual reflete estado da conexão
- Desenho customizado via `paintEvent()`
- Animação de transição entre estados

## Estados

| Estado | Cor | Texto |
|--------|-----|-------|
| `CONNECTED` | 🟢 Verde | Conectado |
| `DISCONNECTED` | 🔴 Vermelho | Desconectado |
| `CONNECTING` | 🟠 Laranja | Conectando |

## Propriedades

- **Dimensões:** width (padrão 55px), height (padrão 25px)
- **Estilo:** BOTÃO ARREDONDADO com indicador deslizante
- **Animação:** Transição suave entre cores

## Sinais

| Sinal | Parâmetro | Descrição |
|-------|-----------|-----------|
| `stateChanged` | `bool` | Estado alterado (True=ligado, False=desligado) |

## Métodos

| Método | Parâmetros | Descrição |
|--------|------------|-----------|
| `setConnectionState()` | `str` | Define estado visual |
| `isChecked()` | - | Retorna estado atual |
| `paintEvent()` | `event` | Desenho customizado |

## Estados Internos

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `_current_state` | `str` | Estado atual: CONNECTED/DISCONNECTED/CONNECTING |
| `_checked` | `bool` | Estado booleano do toggle |

## Integração

```python
self.toggle_switch = ToggleSwitchButton(width=55, height=25)
self.toggle_switch.stateChanged.connect(self._on_toggle_state_changed)
self.toggle_switch.setConnectionState("DISCONNECTED")
```

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*