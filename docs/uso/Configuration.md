---
title: "Configuração de Conexões"
description: "Configuração detalhada de conexões IPsec - formatos legado e swanctl"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [uso, configuracao, ipsec, conexoes]
aliases: [Configuracao, Config]
related:
  - README
  - instalacao/Quick-Start
  - uso/Connecting
  - uso/Logging
  - componentes/IPsecConfigParser
---

# 📋 Configuração de Conexões IPsec

Para que a aplicação possa gerenciar suas conexões VPN, é necessário configurar os arquivos de configuração do IPsec no seu sistema.

## Arquivos de Configuração

A aplicação detecta automaticamente conexões em:

- `/etc/ipsec.conf` (principal)
- `/etc/ipsec.d/*.conf` (adicionais)
- `/etc/strongswan/ipsec.conf` (Fedora/strongSwan 6+)
- `/etc/strongswan/swanctl/conf.d/*.conf` (swanctl)

## Formato de Configuração

### Exemplo Mínimo (ipsec.conf)

```ini
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

### Formato Swanctl (strongSwan 6+)

```ini
conexão-segura {
    local_addrs = 0.0.0.0
    remote_addrs = vpn.empresa.com

    local {
        auth = eap-mschapv2
        eap_identity = "meu_usuario"
    }

    remote {
        auth = psk
    }

    children {
        criança {
            local_ts = 0.0.0.0/0
            remote_ts = 192.168.1.0/24
            esp_proposals = aes256-sha256
        }
    }

    version = 2
    proposals = aes256-sha256-modp2048
}
```

## Configuração de Segredos

Edite `/etc/ipsec.secrets`:

```bash
sudo nano /etc/ipsec.secrets
```

Adicione:

```
: PSK "chave_compartilhada"
meu_usuario : EAP "senha_da_vpn"
```

## Aplicar Configuração

```bash
sudo ipsec rereadall
sudo ipsec restart
sudo ipsec status
```

## Detalhes Detectados pela Aplicação

A aplicação extrai automaticamente:

| Campo | Origem | Exemplo |
|-------|---------|---------|
| Nome da conexão | `conn NOME` | `minha-vpn` |
| Servidor VPN | `right=` | `vpn.empresa.com.br` |
| Autenticação | `leftauth` / `rightauth` | `eap-mschapv2` |
| Protocolos IKE/ESP | `ike=` / `esp=` | `aes256-sha256-ecp256` |
| Sub-rede remota | `rightsubnet=` | `192.168.1.0/24` |

## Multiplas Conexões

Você pode ter múltiplas conexões no mesmo arquivo:

```ini
conn trabalho
    right=vpn.trabalho.com
    ...

conn pessoal
    right=vpn.pessoal.com
    ...
```

## Ambientes com Múltiplos Usuários

- Configurações do sistema: `/etc/ipsec.conf` (compartilhado)
- Configurações por usuário: `~/.config/ipsec.conf` (se aplicação suportar)
- Configurações customizadas: via `VPN_IPSEC_CONF` env var

## Ambientes Especiais

### Bazzite (Fedora Atomic)
```bash
export VPN_IPSEC_CONF=/etc/strongswan/ipsec.conf
export VPN_IPSEC_D_PATH=/etc/strongswan/ipsec.d
```

### Docker Container
```bash
export VPN_IPSEC_BIN=ipsec
export VPN_IPSEC_D_PATH=/etc/ipsec.d
```

---
*[[README|← Voltar]] | [[uso/Connecting|Conectando]] | [[uso/Logging|Logging]]*