---
title: "Setup de Desenvolvimento"
description: "Guia completo para preparar o ambiente de desenvolvimento"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [desenvolvimento, setup, ambiente]
aliases: [Development Setup, Setup Dev]
related:
  - README
  - desenvolvimento/Code-Structure
  - desenvolvimento/Contributing
  - instalacao/Dependencies
---

# 🛠️ Setup de Desenvolvimento

## Pré-requisitos

```bash
sudo apt install -y python3 python3-pip python3-venv git
```

## Clonar e Preparar

```bash
git clone <repo-url>
cd vpn-ipsec-fortigate-client-linux

# Criar ambiente virtual
python -m venv .venv
source .venv/bin/activate

# Instalar dependências
pip install -r requirements.txt

# Instalar strongSwan (para testes)
sudo apt install -y strongswan libstrongswan-extra-plugins
```

## Estrutura de Pastas

```
📂 vpn-ipsec-fortigate-client-linux/
│
├─ main.py                          # Ponto de entrada
├─ requirements.txt                 # Dependências Python
├─ README.md                        # Documentação principal
├─ BAZZITE.md                       # Docs Bazzite
├─ packaging/                       # Scripts de empacotamento
│  ├─ appimage/
│  ├─ deb/
│  ├─ bazzite/
│  ├─ generate_icons.py
│  └─ menu_build.sh
│
├─ src/
│  ├─ ui/                          # Componentes da interface
│  │  ├─ main_window.py
│  │  ├─ connection_config_widget.py
│  │  ├─ toggle_switch_button.py
│  │  ├─ status_log_widget.py
│  │  └─ theme_selector.py
│  │
│  ├─ ipsec/                       # Lógica de negócio IPsec
│  │  ├─ ipsec_manager.py
│  │  ├─ ipsec_commander.py
│  │  └─ ipsec_config_parser.py
│  │
│  ├─ loggers/                     # Gerenciamento de logs
│  ├─ config/                      # Configurações
│  └─ utils/                       # Utilitários
│
├─ assets/
│  ├─ icon.svg
│  └─ styles/
│     ├─ dark_theme.qss
│     └─ light_theme.qss
│
└─ docs/                            # Documentação (você está aqui!)
```

## Execução

```bash
# Desenvolvimento
python main.py

# Com logs no terminal
python -u main.py

# Com debug detalhado
DEBUG=1 python main.py
```

## Testes Manuais

1. Verifique se IPsec está instalado:
```bash
sudo ipsec status
```

2. Crie um arquivo de teste `/etc/ipsec.conf`:
```ini
config setup
    charondebug="ike 2, knl 2, cfg 2, mgr 2"

conn test-vpn
    keyexchange=ikev2
    left=%defaultroute
    leftid="test"
    leftauth=eap-mschapv2
    right=vpn.test.com
    auto=add
```

3. Execute e verifique se a conexão aparece no dropdown

## Debug

### Logs da Aplicação
```bash
# Ver logs
cat ~/.vpnlogs/vpn_ipsec_client.log

# Ver logs com timestamp
tail -f ~/.vpnlogs/vpn_ipsec_client.log
```

### Console do Qt
```bash
# Capturar warnings
QT_LOGGING_RULES="*.debug=true" python main.py
```

### Verificar Socket Único
```bash
# Verificar socket local
lsof | grep vpn-ipsec
```

---
*[[README|← Voltar]] | [[desenvolvimento/Code-Structure|Estrutura de Código]] | [[desenvolvimento/Contributing|Contribuir]]*