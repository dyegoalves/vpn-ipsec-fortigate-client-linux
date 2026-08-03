---
title: "Conectando"
description: "Como conectar, desconectar e configurar conexões VPN"
date: 2026-08-03T04:06:59-03:00
updated: 2026-08-03T04:06:59-03:00
tags: [uso, conectar, vpn, gui]
aliases: [Conectando, Conexao, VPN]
related:
  - README
  - instalacao/Quick-Start
  - uso/Configuration
  - uso/Logging
  - componentes/MainWindow
---

# 🎮 Uso - Conectando

## Conectando/Desconectando

### Interface Gráfica
1. Selecione a conexão no dropdown
2. Use o toggle switch:
   - 🔴 **Desligado** = Desconectado
   - 🟢 **Ligado** = Conectado
3. Status exibido ao lado do toggle:
   - `Desconectado`
   - `Conectando...`
   - `Conectado`
   - `Desconectando...`

### Manual (Terminal)

```bash
# Conectar
sudo ipsec up <nome-conexao>
# Ex: sudo ipsec up minha-vpn

# Desconectar
sudo ipsec down <nome-conexao>
# Ex: sudo ipsec down minha-vpn

# Status
sudo ipsec status          # Todas as conexões
sudo ipsec status <nome>   # Conexão específica
```

## Funcionalidades da UI

### Monitoramento de Status
- Atualização automática a cada 5 segundos
- Toggle switch muda de cor conforme estado
- Ícone da aplicação muda quando conectado

### Sistema de Logs
- Logs visíveis na área inferior da UI
- Botão "Limpar Logs" para limpar display
- Arquivo de log salvo em `~/.vpnlogs/vpn_ipsec_client.log`
- Logs gravados apenas quando conectado

### Integração com Sistema
- Tema segue configuração do sistema (claro/escuro)
- Integração com Deepin (ícone na bandeja, notificações)
- Prevenção de instâncias múltiplas via socket local

### Configurações Adicionais

#### Variáveis de Ambiente
Definir antes de executar:
```bash
export VPN_IPSEC_CONF=/caminho/personalizado/ipsec.conf
export VPN_IPSEC_D_PATH=/caminho/personalizado/ipsec.d
export VPN_IPSEC_BIN=strongswan
export VPN_SWANCTL_BIN=swanctl
```

#### Modo Desenvolvimento
Para logs detalhados:
```bash
python -u main.py 2>&1 | tee debug.log
```

---
*[[README|← Voltar]] | [[instalacao/Quick-Start|Instalação]] | [[uso/Configuration|Configuração Detalhada]] | [[uso/Logging|Sistema de Logs]]*