---
title: "Quick Start"
description: "Guia de instalação rápida do cliente VPN IPsec"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [instalacao, quickstart, guia]
aliases: [Inicio Rapido, QuickStart]
related:
  - README
  - instalacao/Dependencies
  - instalacao/Bazzite
  - uso/Connecting
---

# 🚀 Início Rápido

## 1. Clone e Prepare

```bash
git clone <repo-url>
cd vpn-ipsec-fortigate-client-linux
```

## 2. Ambiente Virtual (Recomendado)

```bash
python -m venv .venv
source .venv/bin/activate
```

## 3. Instale Dependências Python

```bash
pip install -r requirements.txt
```

## 4. Instale StrongSwan

```bash
sudo apt update
sudo apt install -y strongswan strongswan-pki strongswan-swanctl \
  libstrongswan-extra-plugins libxcb-cursor0 libxcb-xinerama0 \
  libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 \
  libxcb-shape0 libxkbcommon-x11-0
```

## 5. Configure IPsec

### Criar/editar `/etc/ipsec.conf`

```bash
sudo nano /etc/ipsec.conf
```

### Exemplo mínimo

```
config setup
    charondebug="ike 2, knl 2, cfg 2, mgr 2"

conn minha-vpn
    keyexchange=ikev2
    ike=aes256-sha256-ecp256
    esp=aes256-sha256
    left=%defaultroute
    leftid="meu_cliente"
    leftauth=eap-mschapv2
    leftdns=8.8.8.8,8.8.4.4
    eap_identity="meu_usuario"
    leftsourceip=%config
    right=vpn.empresa.com.br
    rightid=%any
    rightauth=psk
    rightsubnet=192.168.1.0/24
    auto=add
```

### Configurar segredos

```bash
sudo nano /etc/ipsec.secrets
```

```
: PSK "chave_compartilhada"
meu_usuario : EAP "senha_da_vpn"
```

### Aplicar configuração

```bash
sudo ipsec rereadall
sudo ipsec restart
sudo ipsec status
```

## 6. Execute a Aplicação

```bash
python main.py
```

> **Nota**: Se precisar de sudo para IPsec:
> ```bash
> sudo python main.py
> ```

## Verificação

1. Abre janela "Cliente VPN IPsec Fortigate"
2. Seleciona "minha-vpn" no dropdown
3. Clica no toggle switch (verde = conectado)
4. Verifica logs na área inferior

---
*[[README|← Voltar]] | [[instalacao/Dependencies|Dependências]] | [[instalacao/Bazzite|Bazzite]]*