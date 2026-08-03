---
title: "IPsecConfigParser"
description: "Lê e parseia arquivos de configuração IPsec - formatos legado e swanctl"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ipsec, parser, service-layer]
aliases: [IPsecConfigParser, ParserConfigIPsec]
related:
  - README
  - arquitetura/Components
  - componentes/IPsecCommander
  - componentes/IPsecManager
---

# 📄 IPsecConfigParser

**Arquivo:** `src/ipsec/ipsec_config_parser.py`

## Responsabilidades

- Lê e interpreta arquivos de configuração IPsec
- Suporta formato legado (`conn NAME`) e swanctl (`NAME { ... }`)
- Extrai nomes de conexões e detalhes de configuração

## Formato Legado (ipsec.conf)

```ini
conn fortigate-vpn
    keyexchange=ikev2
    ike=aes256-sha256-ecp256
    esp=aes256-sha256
    right=vpn.example.com
    rightsubnet=192.168.1.0/24
```

## Formato Swanctl (strongSwan 6+)

```ini
connections {
    fortigate-vpn {
        remote_addrs = vpn.example.com
        version = 2
        proposals = aes256-sha256-modp2048
        children {
            child-sa {
                remote_ts = 192.168.1.0/24
            }
        }
    }
}
```

## Diretórios Pesquisados

| Prioridade | Caminho | Formato |
|-----------|---------|---------|
| 1 | `IPSEC_CONFIG_PATHS` (ex: `/etc/ipsec.conf`) | Legado |
| 2 | `IPSEC_D_PATH` (ex: `/etc/ipsec.d/*.conf`) | Legado |
| 3 | `/etc/strongswan/swanctl/conf.d/*.conf` | Swanctl |
| 4 | `/etc/swanctl/conf.d/*.conf` | Swanctl |

## Métodos Principais

| Método | Retorno | Descrição |
|--------|---------|-----------|
| `_get_all_config_files()` | `List[str]` | Coleta todos os arquivos de config |
| `_connection_exists_in_file(conn, file)` | `bool` | Verifica se conexão existe |
| `_parse_connections_from_file(file)` | `List[str]` | Extrai nomes de conexão |
| `find_connection_file(conn)` | `Optional[str]` | Localiza arquivo da conexão |
| `get_connection_details_from_file(file, conn)` | `dict` | Extrai detalhes da conexão |
| `get_server_address_from_details(details)` | `str` | Extrai IP do servidor |

## Detalhes Extraídos

```python
{
    "keyexchange": "ikev2",
    "ike": "aes256-sha256-ecp256",
    "esp": "aes256-sha256",
    "left": "%defaultroute",
    "leftauth": "eap-mschapv2",
    "right": "vpn.example.com",
    "rightsubnet": "192.168.1.0/24",
    "config_file": "/etc/ipsec.conf",
    "conn_name": "fortigate-vpn",
}
```

## Regras de Parsing

- Ignora comentários (`#` e `//`)
- Ignora linhas vazias
- Aceita chaves alfanuméricas com `-` e `_`
- Preserva valores com espaços

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*