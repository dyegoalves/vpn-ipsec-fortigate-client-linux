---
title: "StatusLogWidget"
description: "Widget para exibição de logs de conexão na interface"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ui, widget, logging]
aliases: [StatusLogWidget, LogWidget]
related:
  - README
  - arquitetura/Components
  - componentes/MainWindow
  - componentes/AppLoggers
  - uso/Logging
---

# 📊 StatusLogWidget

**Arquivo:** `src/ui/status_log_widget.py`

## Responsabilidades

- Exibe logs de status em área somente-leitura
- Filtra mensagens rotineiras para evitar poluição da UI
- Fornece botão para limpar o display
- Emite sinal quando o botão de limpar é pressionado

## Sinais Emitidos

| Sinal | Parâmetro | Descrição |
|-------|-----------|-----------|
| `clear_logs_requested` | - | Usuário clicou no botão limpar |

## Interface

### Área de Texto
- `QTextEdit` somente-leitura
- Fonte monoespaçada para melhor legibilidade de logs
- Rolagem automática para mostrar últimas mensagens

### Botão Limpar
- Ícone de lixeira ou lixo (SVG)
- Tooltip: "Limpar logs"
- Emite sinal `clear_logs_requested` ao ser clicado

## Funcionalidade de Filtro

O widget filtra automaticamente mensagens consideradas "rotineiras" para evitar que a UI fique sobrecarregada com atualizações frequentes de status.

## Métodos Principais

| Método | Parâmetros | Descrição |
|--------|------------|-----------|
| `add_message()` | `str` | Adiciona mensagem ao display (aplica filtro) |
| `_is_routine_status_message()` | `str` → `bool` | Determina se mensagem deve ser filtrada |
| `clear_display()` | - | Limpa todo o conteúdo do display |

## Exemplo de Mensagens Exibidas

```
[2026-08-03 10:30:45] Iniciando IPsec conexão: minha-vpn...
[2026-08-03 10:30:46] Conexão estabelecida com minha-vpn.
[2026-08-03 10:30:46] Log file created.
[2026-08-03 10:35:00] Desconectando IPsec conexão: minha-vpn...
[2026-08-03 10:35:01] Desconectado de minha-vpn.
[2026-08-03 10:35:01] Log file closed.
```

## Personalização do Filtro

Para ajustar quais mensagens são filtradas, sobrescreva o método `_is_routine_status_message()`:

```python
def _is_routine_status_message(self, message: str) -> bool:
    return "Status check" in message
```

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*