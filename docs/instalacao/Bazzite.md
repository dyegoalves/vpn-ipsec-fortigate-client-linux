---
title: "Bazzite / Fedora Atomic (OSTree)"
description: "Instruções específicas para instalação em Bazzite e Fedora Atomic"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [bazzite, fedora, atomic, ostree, instalacao]
aliases: [FedoraAtomic, OSTree]
related:
  - README
  - instalacao/Quick-Start
  - instalacao/Dependencies
---

# 🎯 Bazzite / Fedora Atomic (OSTree)

## Visão Geral

Bazzite é Fedora imutável (`rpm-ostree`): `/usr` é somente-leitura. StrongSwan não vem instalado por padrão.

## Instalação Automatizada

```bash
sudo bash packaging/bazzite/install.sh
```

O script:
1. Instala `strongswan` via `rpm-ostree` (exige reboot)
2. Cria venv isolado com PySide6
3. Configura `sudo NOPASSWD` para `ipsec`
4. Instala comando `vpn-ipsec-client` global

## Configuração de Exemplo

Arquivo: `packaging/bazzite/example.ipsec.conf`

```ini
config setup
    charondebug="ike 2, knl 2, cfg 2, mgr 2"

conn bazzite-vpn
    keyexchange=ikev2
    ike=aes256-sha256-ecp256
    esp=aes256-sha256
    left=%defaultroute
    leftid="bazzite_client"
    leftauth=eap-mschapv2
    leftdns=1.1.1.1,8.8.8.8
    eap_identity="usuario"
    leftsourceip=%config
    right=vpn.empresa.com
    rightid=%any
    rightauth=psk
    rightsubnet=10.0.0.0/8
    auto=add
```

Copie para local apropriado:

```bash
sudo cp packaging/bazzite/example.ipsec.conf /etc/strongswan/ipsec.conf
```

## Caminhos Configuráveis

Em distros imutáveis, use variáveis de ambiente:

```bash
export VPN_IPSEC_CONF=/etc/strongswan/ipsec.conf
export VPN_IPSEC_D_PATH=/etc/strongswan/ipsec.d
export VPN_IPSEC_BIN=strongswan
export VPN_SWANCTL_BIN=swanctl
```

## Detalhes Completos

Ver: `packaging/bazzite/README.md`

## Pós-Instalação

```bash
# Reboot necessário após rpm-ostree
systemctl reboot

# Testar
vpn-ipsec-client
```

---
*[[README|← Voltar]] | [[instalacao/Quick-Start|Início Rápido]]*