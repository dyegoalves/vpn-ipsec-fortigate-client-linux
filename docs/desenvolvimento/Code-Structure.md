---
title: "Estrutura de Código"
description: "Estrutura do código fonte e padrões de projeto utilizados"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [desenvolvimento, codigo, estrutura, patterns]
aliases: [Code Structure, Estrutura Codigo]
related:
  - README
  - desenvolvimento/Development-Setup
  - desenvolvimento/Contributing
  - arquitetura/Overview
  - arquitetura/Components
  - arquitetura/Modulos
---

# 📐 Estrutura de Código

## Arquitetura por Camadas

```
┌─────────────────────────────────────────────┐
│  🌐 External                                 │
│  - strongswan / ipsec                        │
│  - swanctl (vici protocol)                   │
└──────────┬──────────────────────────────────┘
           │ subprocess
┌──────────▼──────────────────────────────────┐
│  ⚙️ Service Layer                             │
│  - IPsecCommander (executa comandos)         │
│  - IPsecConfigParser (parseia configs)       │
└──────────┬──────────────────────────────────┘
           │ delegate
┌──────────▼──────────────────────────────────┐
│  💼 Business Logic                             │
│  - IPsecManager (orquestrador)               │
└──────────┬──────────────────────────────────┘
           │ calls
┌──────────▼──────────────────────────────────┐
│  🎨 Presentation Layer                        │
│  - MainWindow                                │
│  - ConnectionConfigWidget                    │
│  - StatusLogWidget                           │
│  - ToggleSwitchButton                        │
│  - ThemeSelectorWidget                       │
└──────────┬──────────────────────────────────┘
           │
┌──────────▼──────────────────────────────────┐
│  ⚙️ Infrastructure                             │
│  - AppConfig (constantes/env vars)           │
│  - AppLoggers (arquivo de log)               │
│  - system_theme (detecção tema)              │
└─────────────────────────────────────────────┘
```

## Fluxos Principais

### 1. Carregamento de Conexões
```
main.py
  └─ MainWindow.__init__
      └─ load_ipsec_config()
          └─ IPsecManager.load_connections()
              ├─ IPsecConfigParser._get_all_config_files()
              └── IPsecConfigParser._parse_connections_from_file()
```

### 2. Conexão VPN
```
MainWindow.toggle_connection()
  └─ MainWindow.connect_vpn()
      └─ IPsecManager.connect_connection()
          └─ IPsecCommander.connect_connection()
              └─ subprocess: sudo ipsec up <conn>
```

### 3. Status
```
MainWindow.refresh_connection_status()
  └─ IPsecManager.get_connection_status()
      └─ IPsecCommander.get_connection_status()
          └─ subprocess: sudo ipsec status
            └─ Analisa output para: "Conectado", "Conectando", "Desconectado"
```

## Padrões de Projeto

| Padrão | Implementação | Benefício |
|--------|--------------|-----------|
| MVC | MainWindow + IPsecManager | Separação UI/lógica |
| Singleton | QApplication | Instância única |
| Observer | Signals/Slots Qt | Comunicação desacoplada |
| Strategy | IPsecCommander | Interface swanctl vs stroke |
| Facade | IPsecManager | Simplifica interface complexa |

## Convenções de Código

- Classes: PascalCase
- Métodos: snake_case
- Constantes: UPPER_SNAKE_CASE
- Variáveis: snake_case
- Docstrings em português

## Importações

```python
# main.py - adiciona src/ ao path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

# Outros módulos usam imports relativos
from ..config.app_config import IPSEC_CONFIG_PATHS
from ..ipsec.ipsec_manager import IPsecManager
```

---
*[[README|← Voltar]] | [[desenvolvimento/Development-Setup|Setup]] | [[desenvolvimento/Contributing|Contribuir]] | [[arquitetura/Overview|Arquitetura]]*