---
title: "ThemeSelectorWidget"
description: "Widget de seleção de tema claro/escuro automático"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ui, widget, tema]
aliases: [ThemeSelectorWidget, SeletorTema]
related:
  - README
  - arquitetura/Components
  - componentes/MainWindow
  - componentes/AppConfig
---

# 🎨 ThemeSelectorWidget

**Arquivo:** `src/ui/theme_selector.py`

## Responsabilidades

- Widget de seleção de tema (Auto/Dark/Light)
- Dropdown com opções de tema
- Notifica quando o usuário muda o tema
- Fornece feedback visual sobre o tema atual

## Sinais

| Sinal | Parâmetro | Descrição |
|-------|-----------|-----------|
| `theme_changed` | `str` | Tema selecionado ("auto", "dark", "light") |

## Interface

### Dropdown (QComboBox)
- Opções: `Auto`, `Dark`, `Light`
- Padrão: `Auto`
- Exibe ícone correspondente ao tema atual

## Integração

```python
# No MainWindow
self.theme_selector = ThemeSelectorWidget()
self.theme_selector.theme_changed.connect(self.handle_theme_change)
layout.addWidget(self.theme_selector)

# Timer para deteção automática (10s quando em modo Auto)
self.theme_timer = QTimer()
self.theme_timer.timeout.connect(self.update_theme)
self.theme_timer.start(10000)
```

## Estilos do Sistema

A detecção do tema é feita via `src/utils/system_theme.py`:

```python
def get_system_color_scheme() -> str:
    """
    Detecta tema do sistema usando gdbus.
    Retorna: "Dark", "Light", ou "Unknown"
    """
```

## Fluxo de Tema

```
1. MainWindow inicia
   └─ get_system_color_scheme()
   └─ apply_theme(tema)

2. Usuário seleciona tema
   └─ theme_changed.emit(tema)
   └─ MainWindow.handle_theme_change()
   └─ apply_theme(tema)

3. Timer (10s, modo Auto)
   └─ get_system_color_scheme()
   └─ Se mudou: apply_theme(novo_tema)
```

## Configuração dos Estilos

| Modo | Fonte do Style Sheet |
|------|---------------------|
| Dark | `src/assets/styles/dark_theme.qss` |
| Light | `src/assets/styles/light_theme.qss` |
| Auto | Detecta sistema e aplica o apropriado |

## Estado Interno

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `selected_theme` | `str` | Último tema selecionado |

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]] | [[arquitetura/Overview|Arquitetura]]*