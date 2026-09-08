# Empacotamento/Instalação para Pop!_OS

O **Pop!_OS** é baseado em Ubuntu/Debian e usa `apt` como gerenciador de pacotes.
A instalação é direta, sem necessidade de técnicas especiais como no Bazzite (sistema imutável).

## Instalar

```bash
sudo ./packaging/pop-os/install.sh
```

O script:
1. Instala `strongswan` e plugins via `apt`;
2. cria um venv isolado em `~/.local/share/vpn-ipsec-client/venv` com o PySide6;
3. grava uma regra segura de sudo **NOPASSWD** para `/usr/sbin/ipsec` para o usuário;
4. instala o launcher `/usr/local/bin/vpn-ipsec-client` + entrada `.desktop`;
5. **remove launchers órfãos** em `~/.local/bin`/`~/bin` e habilita o serviço strongSwan.

> O instalador **não abre a GUI** — rode `vpn-ipsec-client` depois.

## Configurar a VPN

```bash
sudo cp packaging/pop-os/example.ipsec.conf /etc/ipsec.conf
sudo nano /etc/ipsec.secrets   # chaves PSK / EAP
sudo systemctl restart strongswan-starter   # ou: sudo ipsec restart
```

Em seguida rode a GUI:

```bash
vpn-ipsec-client
```

## Bandeja do sistema (system tray)

O Pop!_OS com COSMIC ou GNOME inclui suporte à bandeja do sistema.
O app roda na bandeja sem configuração extra:

- **Conectado**: ícone verde (`vpn-green.png`) na bandeja
- **Desconectado/Erro**: ícone vermelho (`vpn-red.png`) na bandeja
- Tooltip/menu informam o nome da conexão e o status.
- Menu da bandeja: Mostrar/Ocultar Janela, seleção de conexão, Conectar,
  Desconectar e Sair.
- Fechar a janela (X) **minimiza para a bandeja** (VPN continua ativa); **Sair**
  pela bandeja desconecta a VPN antes de encerrar.

## Caminhos configuráveis

O app lê os caminhos IPsec de variáveis de ambiente:

| Variável            | Padrão           |
|---------------------|------------------|
| `VPN_IPSEC_CONF`    | `/etc/ipsec.conf`|
| `VPN_IPSEC_D_PATH`  | `/etc/ipsec.d`   |

## Solução de problemas

| Sintoma | Causa | Correção |
|---|---|---|
| `ipsec: command not found` | strongSwan não instalado | `sudo apt install strongswan` |
| `sudo: a terminal is required` | regra NOPASSWD ausente | rodar o instalador de novo |
| App não abre (Qt falha) | PySide6 do sistema quebrado | usar o venv do instalador |
| Config não é lida | caminho errado | verificar `/etc/ipsec.conf` |

## Desinstalar

```bash
# Parar e desabilitar serviço
sudo systemctl stop strongswan-starter
sudo systemctl disable strongswan-starter

# Remover launcher e desktop entry
sudo rm -f /usr/local/bin/vpn-ipsec-client
sudo rm -f /usr/share/applications/vpn-ipsec-client.desktop

# Remover regra de sudo
sudo rm -f /etc/sudoers.d/vpn-ipsec-client

# Remover venv e configs
rm -rf ~/.local/share/vpn-ipsec-client
sudo rm -f /etc/ipsec.conf /etc/ipsec.secrets

# Remover strongSwan (se não for mais usado)
sudo apt remove strongswan strongswan-pki strongswan-swanctl libstrongswan-extra-plugins libcharon-extra-plugins
```
