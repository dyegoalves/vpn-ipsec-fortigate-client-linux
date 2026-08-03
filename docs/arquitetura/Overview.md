---
title: "Visão Geral da Arquitetura"
description: "Visão geral da arquitetura do cliente VPN IPsec para Linux"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [arquitetura, design, sistema, vpn, ipsec]
aliases: [Arquitetura, System Design]
related:
  - README
  - arquitetura/Components
  - componentes/IPsecManager
  - componentes/AppConfig
---

# 🏗️ Arquitetura

## Stack Tecnológico

- **Linguagem:** Python 3.6+
- **Framework GUI:** PySide6 (Qt6)
- **Comunicação IPsec:** strongswan / ipsec
- **Interface IPC:** QLocalSocket / QLocalServer
- **Estilização:** QSS (Qt Style Sheets)

## Decisões Arquiteturais

### Por que PySide6?
- Integração nativa com ambientes Linux, especialmente Deepin
- Suporte a temas claro/escuro automáticos
- Performance superior a GTK para aplicações desktop

### Separação de Responsabilidades

```
┌─ GUI Layer (UI)
│  │  ├─ [[componentes/MainWindow]]
│  │  ├─ [[componentes/ConnectionConfigWidget]]
│  │  ├─ [[componentes/ToggleSwitchButton]]
│  │  └─ [[componentes/StatusLogWidget]]
│
├─ Business Logic Layer
│  │  └─ [[componentes/IPsecManager]]
│
├─ Service Layer
│  │  ├─ [[componentes/IPsecCommander]]
│  │  └─ [[componentes/IPsecConfigParser]]
│
├─ Configuration Layer
│  │  └─ [[componentes/AppConfig]]
│
└─ Logging Layer
   │  └─ [[componentes/AppLoggers]]
```

## Padrões Utilizados

| Padrão | Implementação | Benefício |
|--------|--------------|-----------|
| MVC | MainWindow + IPsecManager | Separação UI/lógica |
| Singleton | QApplication | Instância única |
| Observer | Signals/Slots Qt | Comunicação desacoplada |
| Strategy | IPsecCommander | Interface swanctl vs stroke |

## Restrições e Limitações

- Requer privilégios `sudo` para gerenciar IPsec
- Suporta apenas Linux (depende de strongswan/ipsec)
- IPC local via socket nomeado (não funciona em NFS)
- Logs apenas quando conectado (design intencional)

---
*[[README|← Voltar]]*