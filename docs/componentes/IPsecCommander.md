---
title: "IPsecCommander"
description: "Executa comandos IPsec e interpreta saídas - suporta swanctl e ipsec"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [componentes, ipsec, commander, service-layer]
aliases: [IPsecCommander, ComandanteIPsec]
related:
  - README
  - arquitetura/Components
  - componentes/IPsecManager
  - componentes/IPsecConfigParser
  - componentes/AppConfig
---

# ⚙️ IPsecCommander

**Arquivo:** `src/ipsec/ipsec_commander.py`

## Responsabilidades

- Executa comandos do sistema via `subprocess`
- Suporta duas interfaces:
  - **swanctl** (strongSwan 6+, protocolo VICI)
  - **ipsec** (legado, protocolo stroke)
- Interpreta saída de comandos para estados da aplicação
- Usa `sudo -n` (sem prompt de senha)

## Comandos Suportados

### Conectar
```python
# strongSwan 6+ (swanctl)
subprocess.run(["sudo", "-n", SWANCTL_BIN, "--initiate", "--child", conn_name])

# Legacy (stroke)
subprocess.run(["sudo", "-n", IPSEC_BIN, "up", conn_name])
```

### Desconectar
```python
# strongSwan 6+ (swanctl)
subprocess.run(["sudo", "-n", SWANCTL_BIN, "--terminate", "--ike", conn_name])

# Legacy (stroke)
subprocess.run(["sudo", "-n", IPSEC_BIN, "down", conn_name])
```

### Status
```python
# strongSwan 6+ (swanctl)
subprocess.run(["sudo", "-n", SWANCTL_BIN, "--list-sas"])

# Legacy (stroke)
subprocess.run(["sudo", "-n", IPSEC_BIN, "status"])
```

## Parsing de Estados

| Palavra-chave na saída | Estado | is_connected |
|------------------------|--------|--------------|
| `ESTABLISHED` | Conectado | `True` |
| `CONNECTING` | Conectando | `False` |
| `IKE_AUTH` | Conectando | `False` |
| `CHILD_CREATE` | Conectando | `False` |
| `initiating` | Conectando | `False` |
| `establishing` | Conectando | `False` |
| (nenhuma SA encontrada) | Desconectado | `False` |

## Tratamento de Erros

### Erros de Sudo
```python
def _is_sudo_error(self, error_msg: str) -> bool:
    return (
        "sudo: a terminal is required" in error_msg
        or "sudo: password is required" in error_msg
        or "sudo: no tty present" in error_msg
    )
```

### Fluxo de Decisão
1. Retorna `True` se `returncode == 0`
2. Verifica mensagens de sucesso específicas
3. Verifica se é erro de sudo
4. Retorna mensagem de erro detalhada

## Seleção Automática de Interface

```python
# Em app_config.py
USE_SWANCTL = bool(SWANCTL_BIN) and "strongswan" in IPSEC_BIN
```

## Notas

- `sudo -n` exige configuração NOPASSWD nas regras de sudo
- Saída é processada em português e inglês
- Erros de timeout não são tratados explicitamente (timeout padrão do subprocess)

---
*[[README|← Voltar]] | [[arquitetura/Components|Componentes]]*