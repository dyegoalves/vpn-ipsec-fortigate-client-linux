---
title: "AppConfig"
description: "Configurações constantes e detecção automática de ambiente"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, configuracao, ambiente]
aliases: [AppConfig, Configuracao]
related:
  - README
  - arquitetura/Components
  - componentes/AppLoggers
  - instalacao/Dependencies
---

# ⚙️ AppConfig

**Arquivo:** `src/config/app_config.py`

## Responsabilidades

- Centraliza constantes, configurações e detecção de ambiente
- Detecta automaticamente binários IPsec disponíveis
- Gerencia variáveis de ambiente para override

## Constantes Principais

| Constante | Tipo | Descrição |
|-----------|------|-----------|
| `APP_TITLE` | `str` | "Cliente VPN IPsec Fortigate" |
| `WINDOW_SIZE` | `tuple` | `(500, 650)` - largura, altura |
| `CONNECTION_STATES` | `dict` | Estados de conexão → labels UI |
| `DEFAULT_MESSAGES` | `dict` | Mensagens padrão do app |

## Detecção Automática

### Binário IPsec
```python
def _detect_ipsec_bin() -> str:
    for candidate in ("strongswan", "ipsec"):
        if shutil.which(candidate):
            return candidate
    return "ipsec"
```

### Binário Swanctl
```python
def _detect_swanctl() -> str:
    for candidate in ("swanctl", "swanctl-legacy"):
        if shutil.which(candidate):
            return candidate
    return ""
```

### Interface Ativa
```python
IPSEC_BIN = _detect_ipsec_bin()
SWANCTL_BIN = _detect_swanctl()
USE_SWANCTL = bool(SWANCTL_BIN) and "strongswan" in IPSEC_BIN
```

## Variáveis de Ambiente (Override)

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `VPN_IPSEC_CONF` | `/etc/ipsec.conf` | Arquivo de config principal |
| `VPN_IPSEC_D_PATH` | `/etc/ipsec.d` | Diretório de configs adicionais |
| `VPN_IPSEC_BIN` | auto | Força binário IPsec |
| `VPN_SWANCTL_BIN` | auto | Força binário swanctl |

## Caminhos de Configuração

### strongSwan 5.x / Legado
- Config principal: `/etc/ipsec.conf`
- Configs adicionais: `/etc/ipsec.d/*.conf`

### strongSwan 6+ (Fedora/OSTree)
- Config principal: `/etc/strongswan/ipsec.conf`
- Configs adicionais: `/etc/strongswan/ipsec.d/*.conf`
- Swanctl configs: `/etc/strongswan/swanctl/conf.d/*.conf`

## Configuração do Qt

```python
os.environ["QT_QPA_PLATFORM"] = "xcb"
```

Força uso do backend XCB para compatibilidade com Deepin.

## Arquivo de Log

```python
LOGS_DIR = os.path.expanduser("~/.vpnlogs")
LOG_FILE_PATH = os.path.join(LOGS_DIR, "vpn_ipsec_client.log")
```

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*