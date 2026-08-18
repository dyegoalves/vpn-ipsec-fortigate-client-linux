# Empacotamento/Instalação para Bazzite

O **Bazzite** é uma distribuição Fedora **imutável** (base `rpm-ostree`). Isso muda a
forma de instalar o Cliente VPN IPsec:

| Item | Bazzite (immutable) | O que fazemos aqui |
|------|--------------------|--------------------|
| strongSwan em `/usr` | não é instalado por padrão | `rpm-ostree install` (em camada) |
| GUI/Qt em `/usr` | root somente-leitura | venv isolado em `~/.local/share` |
| Config em `/etc` | persistente no OSTree | `/etc/ipsec.conf` usado normalmente |
| Sudo | controle granular obrigatório | drop-in `NOPASSWD` para `ipsec` |

## Instalar

```bash
sudo ./packaging/bazzite/install.sh
```

O script:
1. (re)instala `strongswan` + `strongswan-charon-nm` via `rpm-ostree` (tenta `--apply-live`; se precisar, reinicie o sistema);
2. cria um venv isolado em `~/.local/share/vpn-ipsec-client/venv` com o PySide6;
3. grava uma regra segura de sudo **NOPASSWD** para `/usr/sbin/ipsec` para o usuário;
4. instala o launcher `/usr/local/bin/vpn-ipsec-client` + entrada `.desktop`;
5. **remove launchers órfãos** em `~/.local/bin`/`~/bin` (launchers manuais antigos
   apontando para um diretório inexistente viriam **antes** de `/usr/local/bin` no
   `PATH` do usuário e quebrariam o menu) e grava o desktop entry com **caminho
   absoluto** (`Exec=/usr/local/bin/vpn-ipsec-client`).

> O instalador **não abre a GUI** — rode `vpn-ipsec-client` depois.

## Configurar a VPN

```bash
sudo cp packaging/bazzite/example.ipsec.conf /etc/ipsec.conf
sudo nano /etc/ipsec.secrets   # chaves PSK / EAP
sudo systemctl restart strongswan   # ou: sudo ipsec restart
```

Em seguida rode a GUI:

```bash
vpn-ipsec-client
```

## Bandeja do sistema (system tray)

O Bazzite GNOME inclui a extensão **AppIndicator** por padrão, então o app roda
na bandeja sem configuração extra:

- **Conectado**: ícone verde (`vpn-green.png`) na bandeja
- **Desconectado/Erro**: ícone vermelho (`vpn-red.png`) na bandeja
- Tooltip/menu informam o nome da conexão e o status.
- Menu da bandeja: Mostrar/Ocultar Janela, seleção de conexão, Conectar,
  Desconectar e Sair.
- Fechar a janela (X) **minimiza para a bandeja** (VPN continua ativa); **Sair**
  pela bandeja desconecta a VPN antes de encerrar.

## Caminhos alternativos (root imutável)

O app lê os caminhos IPsec de variáveis de ambiente (padrão OSTree):

| Variável            | Padrão           |
|---------------------|------------------|
| `VPN_IPSEC_CONF`    | `/etc/ipsec.conf`|
| `VPN_IPSEC_D_PATH`  | `/etc/ipsec.d`   |

Se preferir manter a config em um local no `/var`, exporte as variáveis
antes de abrir a GUI (o launcher repassa, ex.: `VPN_IPSEC_CONF=/var/lib/ipsec/ipsec.conf`).