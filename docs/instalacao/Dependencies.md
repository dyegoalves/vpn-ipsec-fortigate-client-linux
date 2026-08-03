---
title: "Dependências"
description: "Dependências do sistema e Python para o cliente VPN IPsec"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [dependencias, instale, pre-requisitos]
aliases: [Dependencies, Prerequisitos]
related:
  - README
  - instalacao/Quick-Start
  - instalacao/Bazzite
---

# 📋 Dependências

## Dependências do Sistema

### StrongSwan (obrigatório)
```bash
sudo apt update
sudo apt install -y strongswan strongswan-pki strongswan-swanctl libstrongswan-extra-plugins
```

### Dependências Qt (Deepin/Ubuntu)
```bash
sudo apt install -y libxcb-cursor0 libxcb-xinerama0 libxcb-icccm4 libxcb-image0 \
  libxcb-keysyms1 libxcb-render-util0 libxcb-shape0 libxkbcommon-x11-0
```

## Dependências Python
Lista completa em `requirements.txt`:
- PySide6 >= 6.4
- packaging >= 18.0

## Estrutura Obrigatória do IPsec
### strongSwan 5.x (legado)
- `/etc/ipsec.conf`
- `/etc/ipsec.d/*.conf`
- `/etc/ipsec.secrets`

### strongSwan 6+ (Fedora/OSTree)
- `/etc/strongswan/ipsec.conf`
- `/etc/strongswan/ipsec.d/*.conf`
- `/etc/strongswan/swanctl/conf.d/*.conf`

## Variáveis de Ambiente

| Variável | Descrição | Padrão |
|----------|-----------|--------|
| `VPN_IPSEC_CONF` | Caminho do arquivo de config principal | `/etc/ipsec.conf` |
| `VPN_IPSEC_D_PATH` | Diretório de configs adicionais | `/etc/ipsec.d` |
| `VPN_IPSEC_BIN` | Binário IPsec | auto-detectado |
| `VPN_SWANCTL_BIN` | Binário swanctl | auto-detectado |

## Verificação Rápida
```bash
which strongswan || which ipsec
ipsec version
sudo ipsec status
```

---
*[[README|← Voltar]]*