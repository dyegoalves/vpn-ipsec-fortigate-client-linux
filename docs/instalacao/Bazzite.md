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
5. Remove launchers órfãos em `~/.local/bin`/`~/bin` e usa caminho absoluto no desktop entry

> **Nota:** o instalador **não abre a GUI** — depois de rodar, execute `vpn-ipsec-client` (ou o ícone do menu).

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

## Bandeja do Sistema (System Tray)

O app roda na bandeja (ícone persistente ao lado do relógio):

- Ícone de status (verde = conectado, âmbar = conectando, cinza = desconectado)
- Menu: Mostrar/Ocultar Janela, seleção de conexão, Conectar/Desconectar, Sair
- Fechar a janela (X) **minimiza para a bandeja** — VPN permanece ativa
- **Sair** pela bandeja desconecta a VPN antes de encerrar
- **Single-instance:** rodar o launcher de novo apenas traz a janela para frente

## Posição da Janela

- Abre **centralizada na tela primária**.
- **Lembra a posição/tamanho** (`QSettings`): onde você deixar a janela, ela abre lá na próxima vez.
- Em múltiplos monitores, arraste para o monitor desejado e feche.

## Problema Comum: App não abre pelo menu

Se o app abre no terminal mas **não pelo menu/ícone do desktop**, provavelmente
existe um launcher órfão antigo:

```bash
# Verificar
which -a vpn-ipsec-client
# Se listar algo em ~/.local/bin ANTES de /usr/local/bin, é o problema:
rm -f ~/.local/bin/vpn-ipsec-client

# Depois reindexar o menu
kbuildsycoca6
```

O `install.sh` já faz essa limpeza automaticamente.

---
*[[README|← Voltar]] | [[instalacao/Quick-Start|Início Rápido]]*